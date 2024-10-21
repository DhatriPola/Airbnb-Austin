#!/usr/bin/env python
# coding: utf-8

# In[1]:


pip install pymysql


# In[2]:


import pandas as pd
import glob, os
from sqlalchemy import create_engine
import urllib.parse

# Encode the @ symbol in your password
password = urllib.parse.quote_plus("Dhatri@2001")

# Set the directory where your CSV files are located
directory = '/Users/Admin/Documents/Yo/SQL'  # Replace with your actual directory path

# Change the current working directory to where your CSV files are located
os.chdir(directory)

# Iterate over each CSV file in the directory
for file in glob.glob("*.csv"):
    # Read the CSV file into a pandas DataFrame
    df = pd.read_csv(file)
    
    # Construct the SQLAlchemy engine with the encoded password
    engine = create_engine(f"mysql+pymysql://root:{password}@localhost:3306/airbnb")
    
    # Convert dataframe to SQL table
    df.to_sql(name=file[:-4], con=engine, index=False, if_exists='replace')
    
    print(f'Converted {file} to MySQL table.')

print('All files converted successfully.')


# In[3]:


import pandas as pd
import glob
from sqlalchemy import create_engine
import urllib.parse
import os

# Encode the @ symbol in your password
password = urllib.parse.quote_plus("Dhatri@2001")

# Set the directory where your CSV files are located
directory = '/Users/Admin/Documents/Yo/SQL'  # Replace with your actual directory path

try:
    # Change the current working directory to where your CSV files are located
    os.chdir(directory)
    
    # Iterate over each CSV file in the directory
    for file in glob.glob("*.csv"):
        print(f'Reading {file}...')
        
        # Read the CSV file into a pandas DataFrame
        df = pd.read_csv(file)
        
        # Construct the SQLAlchemy engine with the encoded password
        engine = create_engine(f"mysql+pymysql://root:{password}@localhost:3306/airbnb")
        
        # Convert dataframe to SQL table
        df.to_sql(name=file[:-4], con=engine, index=False, if_exists='replace')
        
        print(f'Converted {file} to MySQL table.')
    
    # Print success message if all files were converted
    print('All files converted successfully.')
    
except Exception as e:
    print(f'Error occurred: {str(e)}')


# In[4]:


import pandas as pd
import glob
from sqlalchemy import create_engine
import urllib.parse
import os

# Encode the @ symbol in your password
password = urllib.parse.quote_plus("Dhatri@2001")

# Set the directory where your CSV files are located
directory = '/Users/Admin/Documents/Yo/SQL'  # Replace with your actual directory path

try:
    # Change the current working directory to where your CSV files are located
    os.chdir(directory)
    
    # Iterate over each CSV file in the directory
    for file in glob.glob("*.csv"):
        try:
            print(f'Reading {file}...')
            
            # Read the CSV file into a pandas DataFrame
            df = pd.read_csv(file)
            
            # Construct the SQLAlchemy engine with the encoded password
            engine = create_engine(f"mysql+pymysql://root:{password}@localhost:3306/airbnb")
            
            # Convert dataframe to SQL table
            df.to_sql(name=file[:-4], con=engine, index=False, if_exists='replace')
            
            print(f'Converted {file} to MySQL table.')
        
        except Exception as e:
            print(f'Error occurred while processing {file}: {str(e)}')
    
    # Print success message if all files were converted
    print('All files converted successfully.')
    
except Exception as e:
    print(f'Error occurred: {str(e)}')


# In[ ]:




