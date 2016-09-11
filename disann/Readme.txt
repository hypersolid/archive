USE DISTRIBUTED NEURAL NETWORK
I. Create data training (existring 2 datas: programs/ann/data.zip (converted), programs/ffnet/data.zip (not converted, ffnet auto convert)
	Step 1: Config file data.txt		
		Line 1: Epochs_in_server   n_input   k_hidden   m_output   total_paterms   paterms_in_unit   epochs_in_client   auto_convert_data(0,1)
		Example: 50 3 5 2 10000 1000 100 1
		Line 2, 3, ....: Data_input_1 data_input_2 ... data_input_n  data_output_1 data_output_2 ... data_output_m
		Example:
		8.0 17.0 88.0 113.0 11968.0
		94.0 56.0 26.0 176.0 136864.0
		52.0 29.0 72.0 153.0 108576.0		
	Step 2: Zip file data.txt => file data.zip

II. Create program (existing 2 programs: programs/ann/program.zip and programs/ffnet/program.zip)
	Step 1: Client's program (in folder client)
		File start.py: Use file_net to train data in file_data and then store weights to file_weight
		#train on data
		file_net = sys.argv[1] 	 		#Address of neural network file on ant
		file_data = sys.argv[2] 		#Address of neural data file on ant
		file_weight=sys.argv[3] 		#Address of weight file on ant (store weight results)
		check_chunk=int(sys.argv[4])  	        #Check for download file data (if check_chunk=1 => not download else download)
		train_data(file_net,file_data,file_weight,1,check_chunk)

	Step 2: Server's program (in folder server)
		File error.py: Plot error from string argv[1]
		error=sys.argv[1].split()
		
		File init_net.py: Create one neural network, if existing file_data then train one times to create auto data, store weights to file_weights
		file_net=sys.argv[1]
		num_input=int(sys.argv[2])
		num_hidden=int(sys.argv[3])
		num_output=int(sys.argv[4])
		file_weights=sys.argv[5]
		file_data=''
		if len(sys.argv)>6:
			file_data=sys.argv[6]
		
		File Update_weights.py: update weights to neural network and then store new neural network
		path_net=sys.argv[1]
		weights=sys.argv[2]
		
		File test.py: Test data in file data/test.txt

	Step 3: Zip folder client an server to file: program.zip
		file_net=sys.argv[1]
		file_test=sys.argv[2]
		num_input=int(sys.argv[3])

II. Run program
	Step 1: Config program 
		Open file settings.py in hill to config:
		SITE_URL
		time_max = 5 #Seconds
		percent_completed = 0.8	 # = 80%
		Acount: Database, username, password
		If not existing data then create data:
			Create database (example: disann)
			Creata data: python manage.py syncdb
			
	Step 2:	Run hill:
		Python manage.py runserver 127.0.0.1:8000
		Or
		Python hillservice.py --startup auto install (with acount admininstrator)
		Python hillservice.py start
		To finished:
		Python hillservice.py stop
		Python hillservice.py remove
	
	Step 3:	Add program
		Open browser (example: firefox => enter SITE_URL (example: 127.0.0.1:8000))
		Browse file program.zip, file data.zip and click add to finish
	
	Step 4: Run ant
		Python start.py
		Or
		Python service.py --startup auto install (with acount admininstrator)
		Python service.py start
		To finished:
		Python service.py stop
		Python service.py remove