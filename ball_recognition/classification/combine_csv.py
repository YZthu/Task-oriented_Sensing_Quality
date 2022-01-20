import csv
import os
import numpy as np
import random
#import requests

deployment_name=["Garage", "Aisle_rug", "Bridge","Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor"]
deployment_name=["Lab_beam","Aisle_beam"]
sensor_list =[1,2,3,4,5,6]
loc_n = 5

write_csv_name ='ext_result_' + str(loc_n) + '.csv'
wr_csv_f = open(write_csv_name, 'w',newline='')
wr_csv = csv.writer(wr_csv_f)
wr_csv.writerow(deployment_name)


for sensor in sensor_list:
    sensor_result= np.zeros([9, len(deployment_name)])
    dep_count = 0
    for dep in deployment_name:
        file_name='./CMs/' + str(dep) + '_'+ str(sensor)+'/' +str(dep) + '_' +str(sensor) + '_' + str(loc_n) + '.csv'
        csv_bar = open(file_name, 'r')
        reader = csv.reader(csv_bar)
        tmp_result=np.zeros(9)
        count =0
        for item in reader:
            if reader.line_num ==1:
                continue
            tmp_result[count] = item[0]
            count = count +1
              
        csv_bar.close()
        sensor_result[:,dep_count] = tmp_result
        dep_count = dep_count+1
        #print(tmp_result)
    print(sensor_result)
    for kk in range(9):
        row_re = sensor_result[kk,:]
        wr_csv.writerow(row_re)
    wr_csv.writerow('\n')
    print('\n\n')
wr_csv_f.close()