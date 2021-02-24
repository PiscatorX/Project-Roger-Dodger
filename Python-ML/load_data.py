#!/usr/bin/env python
import pandas as pd
import collections
import argparse
import pprint
import sys



class GetZeoliteTsv(object):

    def __init__(self,
                 zeolite_filename,
                 zeolite_outfile):

        """ Get zeolite tsv  file exported from excel """
        

        self.zeolite_df = pd.read_csv(zeolite_filename,
                                      delimiter = "\t",
                                      skipinitialspace=True)

        
        print(self.zeolite_df.columns)
        
        self.float_cols = self.zeolite_df.select_dtypes(include=['float64']).columns
        self.zeolite_df.dropna(inplace=True, how = 'all')
        self.zeolite_outfile = zeolite_outfile
        self.df_dtypes = { col: 'category' for col in self.zeolite_df.columns if col not in self.float_cols }
        
    
        
    def set_dtypes(self):

        """ Parse the zeolite data frame, assign categorical/float types"""
        
        print(self.df_dtypes)
        for col in self.df_dtypes:
            try:
                self.zeolite_df[col] = self.zeolite_df[col].astype(self.df_dtypes[col])
            except KeyError as ke:
                print(ke)

        return self.zeolite_df

    

    def zerofill(self, var_col):

        """Fill missing values with zeros"""

        self.zeolite_df[var_col] =  self.zeolite_df[var_col].fillna(0)


        
    def missingness(self):
        
        """ Calculate missingness """

        df_missingness = pd.DataFrame(100 * self.zeolite_df.isnull().sum() / len(self.zeolite_df), columns = ["Missingness"] )

        df_missingness['Feature'] = df_missingness.index

        df_miss = df_missingness[['Feature','Missingness']]

        df_miss = df_miss.round(2)

        df_miss.to_csv(self.zeolite_outfile+'.miss', sep='\t', index = False)


    def MeanImputation(self, var_col):

        """Impute values in one column using group variable columns"""

        #use group means to fill in missing values
        
        self.zeolite_df[var_col] =  self.zeolite_df[var_col].fillna(self.zeolite_df[var_col].mean())
        

        
        
    def GroupMeanImputation(self, grp_var_col, impute_val_col):

        """Impute values in one column using group variable columns"""

        #use group means to fill in missing values
        #Singletons remain NaN
                
        self.zeolite_df[impute_val_col] = \
            self.zeolite_df[impute_val_col].fillna(self.zeolite_df.groupby(grp_var_col)[impute_val_col].transform('mean'))        
        
    
    def encode_categorical(self):


        """ One hot encoding for categorical variables """

        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40
        #convert the categorical variables to intergers also known as one-hot-encoding
        #https://towardsdatascience.com/the-dummys-guide-to-creating-dummy-variables-f21faddb1d40

        categories = [ col for col,dtype in self.df_dtypes.items() if dtype == 'category' ] 
        encoded_categories = [ pd.get_dummies(self.zeolite_df[col]) for col in categories ]
        
        zeolite_dropped = self.zeolite_df.drop(categories, axis= 1)
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
    getZeo.set_dtypes()
    getZeo.missingness()
    getZeo.GroupMeanImputation('Adsorbent','SA')
    getZeo.MeanImputation('SA')
    getZeo.GroupMeanImputation('Adsorbent','Vmicro')
    getZeo.MeanImputation('Vmicro')
    getZeo.GroupMeanImputation('Adsorbent','Vmeso')
    getZeo.MeanImputation('Vmeso')
    getZeo.GroupMeanImputation('Adsorbent','pore_size')
    getZeo.MeanImputation('pore_size')
    getZeo.GroupMeanImputation('Adsorbent','pore_size')
    getZeo.MeanImputation('pore_size')
    getZeo.GroupMeanImputation('Adsorbent','Si_Al')
    getZeo.MeanImputation('Si_Al')
    
    for metal in ['Na', 'Ag', 'Ce', 'Cu', 'Ni', 'Zn', 'Fe3', 'La', 'Cs', 'Pd', 'Nd']:
        getZeo.zerofill(metal)
        
    for var in ["ppm","oil_adsorbent_ratio","Temp"]:
        getZeo.MeanImputation(var)

    #getZeo.encode_categorical()
    getZeo.save_zeo()
