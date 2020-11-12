# -*- coding: utf-8 -*-
"""
Created on Mon Jun  1 18:58:24 2020

#########################################################################################################################
#########################################################################################################################
###################		            							      ###################
###################	title:	             Python Utilities					      ###################
###################		           							      ###################
###################	description:	Useful Python functions			     		      ###################
###################										      ###################
###################	version:	0.0       				                      ###################
###################	notes:	        .							      ###################
###################	bash version:   tested on GNU bash, version 4.2.53			      ###################
###################		           							      ###################
###################	autor: gamorosino     							      ###################
###################     email: g.amorosino@gmail.com						      ###################
###################		           							      ###################
#########################################################################################################################
#########################################################################################################################


@author: gamorosino


"""

import tensorflow_io as tfio 
import tensorflow as tf
import cv2
import os
import numpy as np
import dicom as pydicom
from glob import glob

def NormData(X):
            
            X_orig_dtype=X.dtype
            if X_orig_dtype == np.float64 or X_orig_dtype == np.float32 or X_orig_dtype == np.float16:
                  pass
            else:
                  #print("NormData: convert to float32")
                  X = X.astype(np.float32)  
            result=(X - X.min()) / (X.max() - X.min())
            if len(np.unique(result.astype(X_orig_dtype))) > 5:
                result=result.astype(X_orig_dtype)
            return result
	
def dcm2array(filenameDCM, preproc=False):
        print("Reading the DICOM image...")
        image_bytes = tf.io.read_file(filenameDCM)
        image = tfio.image.decode_dicom_image(image_bytes, dtype=tf.uint16)
        arr=np.squeeze(image.numpy())	
        if preproc:
                print("preproc image...")
                DICOM=pydicom.read_file(filenameDCM,force=True) 
                arr[arr == -2000] = 0
    		# Convert to Hounsfield units (HU)        
                intercept = DICOM.RescaleIntercept
                slope = DICOM.RescaleSlope
                arr = slope * arr.astype(np.float64)
                arr = arr.astype(np.int16)
                arr += np.int16(intercept)

                MIN_BOUND = -1000.0
                MAX_BOUND = 400.0
                arr = (arr - MIN_BOUND) / (MAX_BOUND - MIN_BOUND)
                arr[arr>1] = 1.
                arr[arr<0] = 0.

        return arr

def png2jpg(path_input0,outputpath=None):
 
	if outputpath is None:
		if path_input0[-1] == "/":
			outputpath=os.path.dirname(path_input0[:-1])
		else:
			outputpath=os.path.dirname(path_input0)

		if  outputpath == "":
			outputpath="."
	else:

		try:
			os.mkdir(outputpath)
		except OSError:
			pass
       
	image = cv2.imread(path_input0)
	gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
	jpg_file=outputpath + "/" +  os.path.splitext(os.path.basename(path_input0))[0]+".jpg" 
	cv2.imwrite(jpg_file, gray)
	return

def dcm2jpg(path_input0,outputpath=None, preproc=False):
	factor=255
	if outputpath is None:
		if path_input0[-1] == "/":
			outputpath=os.path.dirname(path_input0[:-1])
		else:
			outputpath=os.path.dirname(path_input0)

		if  outputpath == "":
			outputpath="."


	else:

		try:
			os.mkdir(outputpath)
		except OSError:
			pass
    
	if not os.path.isdir(path_input0):
		ArrayDicom=dcm2array(path_input0,preproc) 
		jpg_file=outputpath + "/" +  os.path.splitext(os.path.basename(path_input0))[0]+".jpg" 
		print("Array Shape:"+str(ArrayDicom.shape))
 
		cv2.imwrite(jpg_file,NormData(ArrayDicom)*factor)

		return
    
	lista_down = os.listdir(path_input0)
	lista_down.sort()

	path = path_input0 + '/'
	src_dcms = glob(path+'*')
	#try:
	if "True" == "True":
		            ##################### CONVERSIONE IN FILE JPG ################################

		            print("reading dicoms")

		            lstFilesDCM = src_dcms
	            
		            for filenameDCM in lstFilesDCM:		        
		            	ArrayDicom=dcm2array(filenameDCM,preproc)
		            	jpg_file=outputpath + "/" +  os.path.splitext(os.path.basename(filenameDCM))[0]+".jpg" 
		            	print("Array Shape:"+str(ArrayDicom.shape))

		            	cv2.imwrite(jpg_file,NormData(ArrayDicom)*factor)
                        
	#except:
	#	print("Error")
	


	
	

