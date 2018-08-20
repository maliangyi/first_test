'''
Created on 2018��8��17��

@author: mly
'''
#!/usr/bin/python
# -*- coding: utf-8 -*-   

import os
import glob
import subprocess
from fnmatch import fnmatch
from fileinput import filename
from tkinter.font import names

if __name__ == '__main__':
    
    #get filename of app
    names = [name for name in os.listdir('./') if os.path.isfile(os.path.join('./',name))]
    for fm in names:
        if os.path.splitext(fm)[1] == '.py':
            names.remove(fm)
    for fm in names:
        if os.path.splitext(fm)[1] == '.py':
            names.remove(fm)
    print(names)
    
    
    
    
    
    
    
    
    #get filename of .py
    names = [name for name in os.listdir('./') if os.path.isfile(os.path.join('./',name))]
    for fm in names:
        #print(fm)
        if fnmatch(fm, '*.py'):
            print(fm)
            out_bytes = subprocess.check_output(['python',fm])   #执行脚本
            out_text = out_bytes.decode('utf-8')
            print(out_bytes)
        
        
        
        
        
        
        
        
        
        
        
        
        
        