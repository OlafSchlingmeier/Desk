*-- Cryptor 5.0 Modes

#DEFINE CR_REGISTER		0x00
#DEFINE CR_ENCODE		0x01
#DEFINE CR_DECODE		0x02
#DEFINE CR_UNREGISTER	0x03
#DEFINE CR_EXEC_FUNC	0x04

*-- Cryptor 5.0 Error Codes

#DEFINE CRYPTOR_ERR_SUCCESS					   0	&& Successful error free execution of function. Not really an error but included for completeness.
#DEFINE CRYPTOR_ERR_FAILED_ALLOCATION		  -3	&& An attempt to allocate memory for Cryptors internal use failed.
#DEFINE CRYPTOR_ERR_FAILED_REALLOCATION		  -4	&& An attempt to reallocate memory for Cryptors internal use failed.
#DEFINE CRYPTOR_ERR_ALREADY_REGISTERED		  -6	&& An attempt was made to register a filename or mask that is a duplicate of one already contained within the registration list.
#DEFINE CRYPTOR_ERR_NOT_REGISTERED			  -7	&& An attempt was made to unregister a filename or mask not contained in the registration list.
#DEFINE CRYPTOR_ERR_HAS_OPEN_FILES			  -9	&& An attempt was made to unregister a filename or mask that is currently in use. i.e a file is open that matches the filename or mask.
#DEFINE CRYPTOR_ERR_FILE_FILENAME_TOO_LONG	 -10	&& An attempt was made to register or unregister a filename or mask that is longer than the maximum length allowed. (260 Characters)
#DEFINE CRYPTOR_ERR_INVALID_FLAGS			 -12	&& The dwFlags parameter contains an invalid value.
#DEFINE CRYPTOR_ERR_HANDLE_OPEN				 -13	&& Internal – attempt to link a handle that has already been linked and exists in the handle table.
#DEFINE CRYPTOR_ERR_TOO_MANY_CLOSES			 -14	&& Internal – attempt to close a handle that has already been closed.
#DEFINE CRYPTOR_ERR_NO_PASSWORD				 -15	&& Internal – attempt to register a filename or mask with no password.
#DEFINE CRYPTOR_ERR_LIST_IN_PROGRESS		 -16	&& A call was made that manipulates the registration table while a list is in progress. Close the list by calling CRYMan_List with CRYPTOR_REGLIST_CLOSE.
#DEFINE CRYPTOR_ERR_NO_LIST_IN_PROGRESS		 -17	&& A call was made to CRYMan_List with CRYPTOR_REGLIST_NEXT before the list operation has been started with CRYPTOR_REGLIST_FIRST.
#DEFINE CRYPTOR_ERR_END_OF_LIST				 -18	&& Not considered an error
#DEFINE CRYPTOR_ERR_BAD_FUNCTION_CODE		 -19	&& An invalid function code was passed as the first parameter to CRYMan_List.
#DEFINE CRYPTOR_ERR_FAILED_RENAME			 -20	&& Cryptor was unable to rename a file
#DEFINE CRYPTOR_ERR_FAILED_DELETE			 -21	&& Cryptor was unable to delete a file
#DEFINE CRYPTOR_ERR_NO_REGISTRATIONS		 -23	&& A call was made to CRYMan_List but there are no entries in the registration table.
#DEFINE CRYPTOR_ERR_FAILED_FOX_ALLOC		 -24	&& 
#DEFINE CRYPTOR_ERR_INVALID_ENC_METHOD		 -25	&& An invalid encryption method was passed to the function.
#DEFINE CRYPTOR_ERR_GETTEMPFILE_FAILED		 -27	&& Internal - A call to GetTempFilename failed.
#DEFINE CRYPTOR_ERR_FAILED_OPEN_SRC			 -28	&& Cryptor was unable to open the source file specified.
#DEFINE CRYPTOR_ERR_FAILED_OPEN_DEST		 -29	&& Cryptor was unable to open the target file specified.
#DEFINE CRYPTOR_ERR_INVALID_CONFIG_ITEM		 -30	&& An incorrect configuartion item as passed.
#DEFINE CRYPTOR_ERR_SHRED_FAILED			 -29	&& Cryptor failed to successfully shred the file specified.
#DEFINE CRYPTOR_ERR_MODULE_NOT_FOUND		-250	&& Cryptor could not find the module specified in memory.
#DEFINE CRYPTOR_ERR_EVALUATION_EXPIRED		-251	&& The evaluation period has expired. Please contact Xitech for an extended evaluation or a full license.
#DEFINE CRYPTOR_ERR_UNITIALIZATION_FAILED	-252	&& A call was made to uninitialize without the system previously being initialized.
#DEFINE CRYPTOR_ERR_NOT_INITIALIZED			-253	&& A call was made to a function that requires the hooking subsystem to be initailized prior to a call to CRYIni_Initialize ot CRYIni_InitializeEx.
#DEFINE CRYPTOR_ERR_ALREADY_INITIALIZED		-254	&& A call was made to CRYIni_Initialize or CRYIni_InitializeEx when either of the functions had already been called for a particular process.
#DEFINE CRYPTOR_ERR_INITIALIZATION_FAILED	-255	&& The hooking subsystem was unable to initialize itself.
#DEFINE CRYPTOR_ERR_UNKNOWN_ERROR			-256	&& An unknown error occurred.

#DEFINE CRYPTOR_ERR_NOT_TABLE				  15	&& Not a table.
#DEFINE CRYPTOR_ERR_FPT_INVALID				  41	&& Memo file "name" is missing or is invalid.
#DEFINE CRYPTOR_ERR_CDX_INVALID				 114	&& Index does not match the table. Delete the index file and re-create the index.
#DEFINE CRYPTOR_ERR_CDX_MISSING				1707	&& Structural .CDX file is not found.
#DEFINE CRYPTOR_ERR_TABLE_CORRUPTED			2091	&& Table has become corrupted. The table will need to be repaired before using again.

*-- Cryptor 5.0 Encryption Methods

#DEFINE ENCODER_DEFAULT			  0		&& Uses the default encryption method set by the SetDefaults program. If SetDefaults has not been used to set the default encryption method Cryptor will resort to ENCODER_WHITESPACE algorithm.
*#DEFINE ENCODER_LEVELn			1-8		&& Cryptor Native Encryption: n is a number between 1 and 8. 1 offering the lowest and simplest level of encryption and 8 offering the highest.
#DEFINE ENCODER_RANDOM_OFF		 16		&& This is a modifier that can be OR'd with one of above ENCODER_LEVELn values. Its effect is to turn off the pseudo-random sequence generator for the above algorithms.
#DEFINE ENCODER_OVERRIDE_SEQ	 32		&& This is a modifier that can be OR'd with one of above ENCODER_LEVELn values. Its effect is not to use the algorithm sequence derived from the product serial number but to use the sequence defined by the set defaults program. This is included for compatibility with Cryptor 1.8.
#DEFINE ENCODER_SIMPLEX			256		&& Simplex encryption is a very simple encryption for rapid operation and good compression. It should be used only for applications that require the minimal encryption and maximmum speed.
#DEFINE ENCODER_WHITESPACE		512		&& The whitespace algorithm uses a pseudo-random sequence generator to encrypt all data except NULL's CHR(0) or SPACE characters CHR(32). This enables the data to be reasonably secured whilst leaving the whitespace redundancy entact allowing the data to be compressed by compression systems such as COMPAxiON or WinZip.

*-- Cryptor 5.0 BackupMode Values

#DEFINE CRYPTOR_KEEPBACKUP		0		&& Leaves the backup file on disk. Note this is the original source file so may be unencrypted.
#DEFINE CRYPTOR_DELETEBACKUP	1		&& Removes the backup file by using a standard delete.
#DEFINE CRYPTOR_SHREDBACKUP		2		&& Removes the backup file by shredding the data first then using a standard delete.

*-- Cryptor 5.0 BackupExt Value

#DEFINE CRYPTOR_BACKUPEXT		"crb"	&& Backup extension value is used during the EncodeFile and DecodeFile methods.