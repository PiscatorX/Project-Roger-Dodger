#!/usr/bin/env python
import argparse
import pandas as pd



def  get_zeo(filename,outfile):

    #importing into pandas dataframe
    zeolite_df = pd.read_csv(filename, delimiter = "\t")

    zeolite_df["Adsorbent"]

    for var in ["SA","Vmicro","Vmeso","pore size","Si_Al","Ag","Ce","Cu","C_start","C_end", "adsorbent"]:
            #zeolite_df[var] =  zeolite_df[var].fillna(0)
            zeolite_df[var] =  zeolite_df[var].astype('float64')

    for var in ["Adsorbent","adsorbate","solvent","Batch_Dynamic"]:
        zeolite_df[var] =  zeolite_df[var].astype('category')

    zeolite_df['References'] = zeolite_df['References'].astype('string')

    #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
    #convert the categorical variables to intergers also known as one-hot-encoding
    #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
    #This can be automated to identify only those categorical variables, encode them and save them to a list for concat
    encoded_Adsorbent = pd.get_dummies(zeolite_df['Adsorbent'])
    encoded_solvent = pd.get_dummies(zeolite_df['solvent'])
    #No need to encode this, all values appear to be same?
    #encoded_adsorbate = pd.get_dummies(zeolite_df['adsorbate'])
    encoded_Batch_Dynamic = pd.get_dummies(zeolite_df['Batch_Dynamic'])

    encoded_Adsorbent

    #remove the categorical variable columns and any unwanted columns in this case "References"
    #this can also be automated as part of the step abov
    zeolite_dropped = zeolite_df.drop(["Adsorbent","solvent","adsorbate","Batch_Dynamic", "References"],axis= 1)
    #zeolite_dropped.dtypes

    #encoded_Adsorbent
    encoded_solvent 
    #encoded_Batch_Dynamic  

    zeolite_final = pd.concat([zeolite_dropped, encoded_solvent, encoded_Adsorbent, encoded_Batch_Dynamic],axis=1 )

    zeolite_dropped

    #We have our data ready for machine learning
    zeolite_final.dtypes
    #saving dataframe to file for optimisation
    zeolite_final.to_csv(outfile, sep='\t', index = False)

    return zeolite_final
        
if  __name__  == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-z','--zeolite_file',help ="sequence file", type=argparse.FileType('r'), default = "/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv", required=False)
    parser.add_argument('-o','--outfile', default = "zeolitex_final.tsv", type=argparse.FileType('w'), required = False)
    args = parser.parse_args()
    get_zeo(args.zeolite_file, args.outfile)



