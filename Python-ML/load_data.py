#!/usr/bin/env python
import pandas as pd
import collections
import argparse
import pprint
import sys



class GetZeoliteTsv(object):

    def __init__(self,
                 zeolite_filename,
                 zeolite_outfile,
                 categorical_cols = ["Adsorbent","adsorbate","solvent","Batch_Dynamic"]):

        """ Get zeolite tsv  file exported from excel """
        

        self.zeolite_df = pd.read_csv(zeolite_filename,
                                      delimiter = "\t",
                                      skipinitialspace=True)
        self.zeolite_outfile = zeolite_outfile
        self.categorical_cols = categorical_cols
        self.float_cols = list(set(self.zeolite_df.columns) - set(self.categorical_cols))

        
    def parse_zeo(self):

        """ Parse the zeolite data frame, assign dytpes and impute missing values"""
        
        for float_var in self.float_cols:
            
            self.zeolite_df[float_var] =  self.zeolite_df[float_var].astype('float64')

        for cat_var in self.categorical_cols:
            self.zeolite_df[cat_var] =  self.zeolite_df[cat_var].str.rstrip().astype('category')

        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
        #convert the categorical variables to intergers also known as one-hot-encoding
        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
        #This can be automated to identify only those categorical variables, encode them and save them to a list for concat
        encoded_Adsorbent = pd.get_dummies(self.zeolite_df['Adsorbent'])
        encoded_solvent = pd.get_dummies(self.zeolite_df['solvent'])

        #No need to encode this, all values appear to be same?
        encoded_adsorbate = pd.get_dummies(self.zeolite_df['adsorbate'])
        encoded_Batch_Dynamic = pd.get_dummies(self.zeolite_df['Batch_Dynamic'])

        #remove the categorical variable columns and any unwanted columns in this case "References"
        #this can also be automated as part of the step above
        zeolite_dropped =self.zeolite_df.drop(["Adsorbent","solvent","adsorbate","Batch_Dynamic"],axis= 1)  
        zeolite_final = pd.concat([zeolite_dropped,
                                   encoded_solvent,
                                   encoded_Adsorbent,
                                   encoded_Batch_Dynamic],
                                   axis=1 )

#     SA_imputation(zeolite_df)
#     sys.exit(1)
#     zeolite_dropped
#     #We have our data ready for machine learning
#     zeolite_final.dtypes
#     #saving dataframe to file for optimisation
#     
#     return zeolite_final



    def GroupMeanImputation(self, grp_var_col, impute_val_col):

        """Impute values in one column using group variable columns"""

        #use group means to fill in missing values
        #Singletons remain NaN
        self.zeolite_df[impute_val_col] = \
            self.zeolite_df[impute_val_col].fillna(self.zeolite_df.groupby(grp_var_col)
                                                                                             [impute_val_col].transform('mean'))

        

    def save_zeo(self):

        """Save zeolite to tsv for training"""

        self.zeolite_final.to_csv(outfile, sep='\t', index = False)  


    
if  __name__  == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('zeolite_file', help ="sequence file", type=argparse.FileType('r'))
    parser.add_argument('-o','--outfile', default = "zeolitex_final.tsv", type=argparse.FileType('w'), required = False)
    args = parser.parse_args()
    getZeo = GetZeoliteTsv(args.zeolite_file, args.outfile)
    getZeo.parse_zeo() 
    getZeo.GroupMeanImputation('Absorbent','SA')

