import numpy as np
from sklearn.covariance import LedoitWolf
from sklearn.model_selection import StratifiedShuffleSplit
from sklearn.preprocessing import LabelEncoder
from mne.parallel import parallel_func


def _mean_by_condition(X, conds):
    """
    computes the average of each condition in X, ordered by conds
    returns a n_conditions x n_channels array
    """
    avs = np.zeros((len(np.unique(conds)), *X.shape[1:]))
    for cond in sorted(np.unique(conds)):
        X_cond = X[conds == cond]
        avs[cond] = X_cond.mean(axis=0)
    return avs


def _means_and_prec(X, conds):
    """
    Returns condition averages and demeaned inverse covariance
    Covariance is regularized by ledoit-wolf procedure
    """
    cond_means = _mean_by_condition(X, conds)
    cond_means_for_each_trial = cond_means[conds]
    X_demean = X - cond_means_for_each_trial  # demean

    return cond_means, LedoitWolf(assume_centered=True).fit(X_demean).precision_


def _calc_rdm_crossnobis_single(meas1, meas2, noise):
    """
    Calculates RDM using crossnobis distance using means from x and y, and covariance
    Largely taken from https://github.com/rsagroup/rsatoolbox/blob/main/src/rsatoolbox/rdm/calc.py#L429
    Updated to return the signed square root of the RDM because
    LDC is an estimator of the squared mahalonobis distance
    """
    kernel = meas1 @ noise @ meas2.T
    rdm = np.expand_dims(np.diag(kernel), 0) + np.expand_dims(np.diag(kernel), 1) - kernel - kernel.T
    return np.sign(rdm) * np.sqrt(np.abs(rdm))


def _crossnobis_single(X_train, conds_train, X_test, conds_test):
    """
    Uses condition means from both train and test, but only uses the training
    examples to compute the noise covariance/precision matrix. You may have another
    preference, but I did it this way to avoid train-test leakage.
    """
    means_train, noise_train = _means_and_prec(X_train, conds_train)
    means_test = _mean_by_condition(X_test, conds_test)
    rdm = _calc_rdm_crossnobis_single(means_train, means_test, noise_train)
    return rdm


def _crossnobis_train_test_across_time(Xdata, y, train, test, cond_order, balance_func=None):
    # assumes Xdata is n_trials x n_features x n_times

    X_train, y_train = Xdata[train], y[train]
    X_test, y_test = Xdata[test], y[test]
    if balance_func:
        X_train, y_train, X_test, y_test = balance_func(X_train, y_train, X_test, y_test)

    # calculate RDMS over time for this fold
    rdms = [_crossnobis_single(X_train[..., t], y_train, X_test[..., t], y_test) for t in range(Xdata.shape[-1])]

    # concatenate over time and resort to the given cond_order
    return np.stack(rdms, axis=2)[np.ix_(cond_order, cond_order)]


def crossnobis(Xdata, ydata, cond_order, test_size=0.5, n_splits=1000, n_jobs=-1, **kwargs):
    """
    Wrapper for a parallel function to calculate a series of crossnobis distances
    n_splits and n_jobs should be given as arguments upon class initialization


    """
    enc = LabelEncoder()  # converts condition labels to integer codes
    conds = enc.fit_transform(ydata)
    cond_order = enc.transform(cond_order)  # how to resort the final RDMs

    cv = StratifiedShuffleSplit(n_splits=n_splits, test_size=test_size)

    parallel, p_func, _ = parallel_func(_crossnobis_train_test_across_time, n_jobs)
    rdms = parallel(p_func(Xdata=Xdata, y=conds, train=train_idx, test=test_idx, cond_order=cond_order, **kwargs) for train_idx, test_idx in cv.split(Xdata, conds))

    rdms = np.stack(rdms, axis=0)
    return rdms.mean(0)  # average over folds
