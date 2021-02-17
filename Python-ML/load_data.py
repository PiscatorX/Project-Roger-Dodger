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
                 categorical_cols = ["Adsorbent", "S", "adsorbate","solvent","Batch_Dynamic"]):

        """ Get zeolite tsv  file exported from excel """
        

        self.zeolite_df = pd.read_csv(zeolite_filename,
                                      delimiter = "\t",
                                      skipinitialspace=True)

        
        self.df_cols = self.zeolite_df.columns
        self.zeolite_outfile = zeolite_outfile
        self.col_dtype = { col: 'category' for col in categorical_cols if col in self.zeolite_df.columns }
        
        print(self.df_cols)
        
        self.col_dtype.update({col: 'float64' for col in self.df_cols if col not in categorical_cols })
    
        
    def parse_zeo(self):

        """ Parse the zeolite data frame, assign dytpes and impute missing values"""

        for col in self.df_cols:
            try:
                self.zeolite_df[col] = self.zeolite_df[col].astype(self.col_dtype[col])
            except KeyError as ke:
                print(ke)

                
        return self.zeolite_df


    def missingness(self):

        print(self.zeolite_df)
        

        
    def GroupMeanImputation(self, grp_var_col, impute_val_col):

        """Impute values in one column using group variable columns"""

        #use group means to fill in missing values
        #Singletons remain NaN
                
        self.zeolite_df[impute_val_col] = \
            self.zeolite_df[impute_val_col].fillna(self.zeolite_df.groupby(grp_var_col)[impute_val_col].transform('mean'))        
        
    
    def encode_categorical(self, *categories):


        """ One hot encoding for categorical variables """

        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
        #convert the categorical variables to intergers also known as one-hot-encoding
        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
        
        encoded_categories = [ pd.get_dummies(self.zeolite_df[category]) for category in categories ]
        
        zeolite_dropped = self.zeolite_df.drop(list(categories), axis= 1)
        self.zeolite_df = pd.concat( [zeolite_dropped] + encoded_categories, axis=1)
 
            
    def save_zeo(self):

        """Save zeolite to tsv for training"""

        self.zeolite_df.to_csv(self.zeolite_outfile, sep='\t', index = False)  


if  __name__  == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('zeolite_file', help ="sequence file", type=argparse.FileType('r'))
    parser.add_argument('-o','--outfile', default = "ZeoX_Final.tsv", required = False)
    args = parser.parse_args()
    getZeo = GetZeoliteTsv(args.zeolite_file, args.outfile)
    getZeo.parse_zeo() 
    getZeo.GroupMeanImputation('Adsorbent','SA')
    #getZeo.encode_categorical("Adsorbent","solvent","adsorbate","Batch_Dynamic")
    getZeo.encode_categorical("Adsorbent","solvent","Batch_Dynamic")
    getZeo.save_zeo()
