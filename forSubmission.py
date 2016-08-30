# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
import pandas as pd
import os

os.chdir('C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project')

predict_df = pd.read_csv('H2O Model Results/2016-04-12-01 RF.csv')
#test_set = pd.read_csv('Kaggle Project/SF Data/test.csv')
sample_submission = pd.read_csv('SF Data/sampleSubmission.csv')

id_list = sample_submission['Id']
sample_submission.drop(["Id"], axis=1,inplace=True)
predict_df.drop(["predict"], axis=1,inplace=True)
#test_ids = test_set.Id
cols = predict_df.columns
pred_arr = predict_df.values
sub_arr = np.zeros_like(pred_arr)
sub_arr[np.arange(len(pred_arr)), pred_arr.argmax(1)] = 1
sub_df = pd.DataFrame(sub_arr)
sub_df.columns = sample_submission.columns
sub_df.insert(0,'Id', value = id_list)
sub_df.to_csv('Submissions/2016-04-12-01 RF.csv', index = False)