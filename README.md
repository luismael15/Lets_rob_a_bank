# Lets_rob_a_bank
Development of a simple predictive model to detect fraudulent transactions in R.

The train.csv attachment contains information about many credit and debit card transactions through different channels. For each transaction there is the monetary value of the same and other variables. Information of 6 months, of clients and criminals transacting abroad with a present card, that is, NO internet, face-to-face purchases.
The missing data in the distances is generally because the client does not have any route that allows the calculation to be made.

Here it is the list of features (Names are in Spanish):

Name	Description

ID	Id Cliente
FRAUDE	1= Fraud; 0=No fraud
VALOR	transaction value
HORA_AUX	Transaction time, without minutes or seconds
Dist_max_NAL	Maximum distance traveled nationally (in miles)
Canal1	Transactional channel of the transaction, including types of dataphones
FECHA	Date of occurrence of the transaction
COD_PAIS	Country of occurrence of the transaction. View Internet ISO code
CANAL	Transaction channel of the transaction
DIASEM	Day of the week the transaction was made
DIAMES	Day of the month the transaction was made
FECHA_VIN	Customer bonding date
OFICINA_VIN	Client Office
SEXO	M, F
SEGMENTO	customer segment
EDAD	Customer Age
INGRESOS	Customer income
EGRESOS	customer expenses
NROPAISES	# countries visited 
Dist_Sum_INTER	Sum of distance traveled internationally (in miles)
Dist_Mean_INTER	Average distance traveled internationally (in miles)
NROCIUDADES	Number of national cities visited
Dist_Sum_NAL	Sum distance traveled nationally (in miles)
Dist_Mean_NAL	Maximum distance traveled nationally (in miles)
Dist_HOY	Difference between the last current transaction made and the transaction being made today


Please feel free to improve or comment my first project in R. 
