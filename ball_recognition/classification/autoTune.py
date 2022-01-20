'''
This is the code to do the automatic grid search.
'''

# import libraries and packages
import warnings
from numpy.lib.function_base import place
warnings.filterwarnings(action="ignore")
import pandas as pd
import os
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn import metrics
from sklearn.metrics import confusion_matrix
from xgboost import XGBClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import RandomizedSearchCV
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
from sklearn.preprocessing import StandardScaler

from tuning import *

def splitData(df):

    #g = df.groupby('Var1')
    #data = pd.DataFrame(g.apply(lambda x: x.sample(g.size().min()).reset_index(drop=True)))
    X = df.iloc[:,1:]
    y = df.iloc[:,0]
    return (X, y)

def measure(model, xTrain, yTrain, xTest, yTest,cvs):
    # To get the baseline performance
    skf = StratifiedKFold(n_splits=cvs)
    scores = cross_val_score(model, xTrain, yTrain, cv=skf)
    print("Stratified CV Accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
    print("Scores: ", scores)
    model.fit(xTrain, yTrain)
    testAcc = model.score(xTest, yTest)
    print("Test Accuracy: %0.2f" % (testAcc))


def tune(X_train, y_train, X_test, y_test, cvNum, dep, location, runIdx, savePath = './'):
    '''
    Tuning each model in the inner loop of nested CV. 
    cvNum: The number of runs of stratified CV. Get from other functions.
    dep: Deployment name, e.g. aisle rug
    location: location id and location node name, e.g: '1_3' staands for location 1 location 3
    runIdx: The index of outer loop
    savePath: The folder to save the .npz and .txt files
    '''
    # Stratified K-flod CV
    skf = StratifiedKFold(n_splits=cvNum)
    # Initializing the classifiers
    clf_lsvm = svm.SVC(kernel='linear') # Linear SVM
    clf_rsvm = svm.SVC(kernel='rbf') # RBF SVM
    clf_rf = RandomForestClassifier() # Random Forest
    clf_lr = LogisticRegression() # Logistic Regression
    clf_adb = AdaBoostClassifier() # AdaBoost
    clf_nb = GaussianNB() # Gaussian Naive Bayes
    clf_xgb = XGBClassifier(objective='multi:softmax',n_jobs=18) # XG Boost
    clf_knn = KNeighborsClassifier(n_neighbors=5) # kNN
    clf_etr = ExtraTreesClassifier() # Extra Trees
    
    # Start to tune!
    # SVM Family
    print('SVM')
    accLsvm, accRsvm = svmTuning(X_train, y_train, X_test, y_test, clf_lsvm, clf_rsvm, skf, dep, location,runIdx, savePath)
  
    # Random Forest
    print('Random Forest')
    accRf = 1#rfTuning(X_train, y_train, X_test, y_test, clf_rf, skf, dep, location,runIdx, savePath)

    # LR
    print('LR')
    accLr = 1#lrTuning(X_train, y_train, X_test, y_test, clf_lr, skf, dep, location,runIdx, savePath)
    
    # AdaBoost
    accAdb = 1#adbTuning(X_train, y_train, X_test, y_test, clf_adb, skf, dep, location,runIdx, savePath)

    # Gaussian Naive Bayes
    print('Gaussian Naive Bayes')
    accNb = 1#nbEval(X_train, y_train, X_test, y_test, clf_nb, skf, dep, location,runIdx, savePath)
    
    # XGB
    print('XGBoost')
    accXgb = 1#xgTuning(X_train, y_train, X_test, y_test, clf_xgb, skf, dep, location,runIdx, savePath)

    # kNN
    print('Knn')
    accKnn = 1#knnTuning(X_train, y_train, X_test, y_test, clf_knn, skf, dep, location,runIdx, savePath)

    # Extra Trees
    print('Extra Trees')
    accEt = 1#etTuning(X_train, y_train, X_test, y_test, clf_etr, skf, dep, location,runIdx, savePath)

    return (accLsvm, accRsvm, accRf, accLr, accAdb, accNb, accXgb, accKnn, accEt)

def crossTune(dep, location, loc_n, num_folds, sourcePath = './', savePath = './', normalization = False):
    '''
    Nested CV for a dataset. e.g. './data/1_3/'
    dep: Deployment name, e.g. aisle rug
    location: location id, e.g: '_3' staands for location 3
    savePath: The folder to save the .npz and .txt files
    '''
    dfPath = sourcePath + dep + "_" + str(location) + "_" + str(loc_n+1) + ".csv"
    df = pd.read_csv(dfPath)    
    #df = df.iloc[:,9:400]
    X, y = splitData(df)
    
    outerCV = StratifiedKFold(n_splits = num_folds, random_state=None, shuffle=False)
    scaler = StandardScaler()

    # Places to store the performance
    lsvmList = list()
    rsvmList = list()
    rfList = list()
    lrList = list()
    adbList = list()
    nbList = list()
    xgbList = list()
    knnList = list()
    etList = list()
    # innerCV = StratifiedKFold(n_splits=(sampleNum - 1), random_state=None, shuffle=False) #One test set has been spared for test, so the splits should ,minus 1
    i = 0
    for train_index, test_index in outerCV.split(X, y):
        # print(train_index)
        i += 1
        # Get the outer loop train and test
        # This can be viewed as the X and y for the inner loop
        X_train = X.iloc[train_index]
        y_train = y.iloc[train_index]
        X_test = X.iloc[test_index]
        y_test = y.iloc[test_index]

        if normalization:
            X_train = scaler.fit_transform(X_train)
            X_test = scaler.transform(X_test)

        acc_Lsvm, acc_Rsvm, acc_Rf, acc_Lr, acc_Adb, acc_Nb, acc_Xgb, acc_Knn, acc_Et = tune(X_train, y_train, X_test, y_test, num_folds - 1, dep, str(location), str(i), savePath)
        lsvmList.append(acc_Lsvm)
        rsvmList.append(acc_Rsvm)
        rfList.append(acc_Rf)
        lrList.append(acc_Lr)
        adbList.append(acc_Adb)
        nbList.append(acc_Nb)
        xgbList.append(acc_Xgb)
        knnList.append(acc_Knn)
        etList.append(acc_Et)

    lsvmList = np.array(lsvmList)
    rsvmList = np.array(rsvmList)
    rfList = np.array(rfList)
    lrList = np.array(lrList)
    adbList = np.array(adbList)
    nbList = np.array(nbList)
    xgbList = np.array(xgbList)
    knnList = np.array(knnList)
    etList = np.array(etList)
    
    print("LSVM Accuracy: %0.2f (+/- %0.2f)" % (lsvmList.mean(), lsvmList.std()))
    print("RSVM Accuracy: %0.2f (+/- %0.2f)" % (rsvmList.mean(), rsvmList.std()))
    print("RF Accuracy: %0.2f (+/- %0.2f)" % (rfList.mean(), rfList.std()))
    print("LR Accuracy: %0.2f (+/- %0.2f)" % (lrList.mean(), lrList.std()))
    print("Adb Accuracy: %0.2f (+/- %0.2f)" % (adbList.mean(), adbList.std()))
    print("NB Accuracy: %0.2f (+/- %0.2f)" % (nbList.mean(), nbList.std()))
    print("XGB Accuracy: %0.2f (+/- %0.2f)" % (xgbList.mean(), xgbList.std()))
    print("kNN Accuracy: %0.2f (+/- %0.2f)" % (knnList.mean(), knnList.std()))
    print("ET Accuracy: %0.2f (+/- %0.2f)" % (etList.mean(), etList.std()))

    d = {"Accuracy":[lsvmList.mean(), rsvmList.mean(), rfList.mean(), lrList.mean(), adbList.mean(), nbList.mean(), xgbList.mean(), knnList.mean(), etList.mean()],
        "STD":[lsvmList.std(), rsvmList.std(), rfList.std(), lrList.std(), adbList.std(), nbList.std(), xgbList.std(), knnList.std(), etList.std()]}
    df = pd.DataFrame(data=d) #The dataframe for the average accuracy and Standard Deviation

    dfSavePath = savePath + dep + "_" + str(location) + "_" + str(loc_n+1) + ".csv"
    df.to_csv(dfSavePath, index=False) #Save the CSV

import time

deployment_name1 = ["Garage","Aisle_rug","Bridge"]
deployment_name2 = ["Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor"]
deployment_name3 = ["Lab_beam","Aisle_beam"]

deployment_name = deployment_name3
sensor_list = [5,6]
folds = 5
normalize = True

start = time.time()
for deployment in deployment_name:
    for sensorID in sensor_list:
        for loc_n in range(5):
            place_to_save = "./CMs/" + deployment + "_" + str(sensorID) + "/"
            #print(~(os.path.exists(place_to_save)))
            if os.path.exists(place_to_save)==False:
                os.mkdir(place_to_save)
            crossTune(deployment, sensorID, loc_n, num_folds = folds, sourcePath = './ball_1345_csv/', savePath = place_to_save, normalization = normalize)

end = time.time()
print('Time Consumption: ', (end - start),' seconds.')
