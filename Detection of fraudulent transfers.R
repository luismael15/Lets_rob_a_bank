rm(list= ls())
cat('\014')

# 1. Libraries
library(ggplot2)
library(caret)
library(lattice)
library(dplyr)
library(e1071) 
library(pROC)
library(lmtest)



# 2. Database 

datos <- read.csv("~/DATAHACK MASTER/1. CURSO/1.2 Data Analytics/Practica Oficial/GITHUB/train (1).csv", stringsAsFactors = T)


# 3. Train y Test (80-20). set.seed(51) and our target is "Fraude"

set.seed(51)

data_particion <- createDataPartition(datos$FRAUDE, p = .8,
                                      list = FALSE,
                                      times = 1)
train <- datos[ data_particion,]

test_Fraude<- datos[-data_particion,]
test <- select(test_Fraude,-FRAUDE)

# 4.Feature engineering 

train <- select(train,-id, -Canal1, -OFICINA_VIN, - HORA_AUX,-DIASEM,-DIAMES)

summary(train)
str(train)


# antiquity of the client in years

train$FECHA_VIN <- as.Date(as.character(train$FECHA_VIN),
                           format = "%Y%m%d")
max_date <- as.Date(as.character(20150427),
                    format = "%Y%m%d") 

train$Antiguedad <- max_date-train$FECHA_VIN

train$Antiguedad <- as.integer(train$Antiguedad/365)

train <- select(train,-FECHA_VIN)

# Na as ceros

train$INGRESOS[is.na(train$INGRESOS)] <- 0
train$EGRESOS[is.na(train$EGRESOS)] <- 0
train$Dist_Sum_INTER[is.na(train$Dist_Sum_INTER)] <- 0
train$Dist_Mean_INTER[is.na(train$Dist_Mean_INTER)] <- 0
train$Dist_Max_INTER[is.na(train$Dist_Max_INTER)] <- 0
train$Dist_Mean_NAL[is.na(train$Dist_Mean_NAL)] <- 0
train$Antiguedad[is.na(train$Antiguedad)] <- 0

# Rows with Na "EDAD" are less than 20 so we delete them

train$EDAD[is.na(train$EDAD)] <- na.omit(train$EDAD)

# "SEXO" AND "SEGMENTO" MISSING VALUES

train$SEXO[train$SEXO == "" | train$SEXO == " "] <- NA
train$SEXO <- as.character(train$SEXO)
train$SEXO[is.na(train$SEXO)] <- "Sin determinar"
train$SEXO <- as.factor(train$SEXO)


train$SEGMENTO[train$SEGMENTO == "" | train$SEGMENTO == " "] <- NA
train$SEGMENTO <- as.character(train$SEGMENTO)
train$SEGMENTO[is.na(train$SEGMENTO)] <- "Sin determinar"
train$SEGMENTO <- as.factor(train$SEGMENTO)


#5. Modeling with step for a first approximation

start_time <- Sys.time()
mod <- step(glm(FRAUDE~ ., data=train), direction='both')
end_time <- Sys.time()
end_time - start_time

length(mod$coefficients)
summary(mod)

#logistic model, we will take into account the variables that have given the best aic in the previous step.
#in order to avoid multicollinearity, we won't include all distance feature, only the most representative

model_1 <- glm(FRAUDE ~ VALOR + Dist_max_NAL + COD_PAIS + CANAL  
                 + SEGMENTO + EDAD + Dist_Sum_INTER,
               data = train)

summary(model_1)


model_2 <- glm(FRAUDE ~ VALOR + Dist_max_NAL + COD_PAIS + CANAL  
               + EDAD + Dist_Sum_INTER,
               data = train)

summary(model_2)

model_3 <- glm(FRAUDE ~ VALOR + Dist_max_NAL + COD_PAIS + CANAL  
               + EDAD + Dist_Sum_INTER+ Antiguedad,
               data = train)

summary(model_3)


#6. Evaluation train

#PREDICTIONS

predictions_train <- predict(model_1,
                             newdata = train,
                             type = 'response')
train <- cbind(train, predictions_train)
head(train)

train$FRAUDE_predictions_train <- train$predictions_train > 0.5
train$FRAUDE_predictions_train <- as.numeric(train$FRAUDE_predictions_train)
# Confusion matrix
table(train$FRAUDE_predictions_train , train$FRAUDE)
round(prop.table(table(train$FRAUDE_predictions_train , train$FRAUDE)),2)

#AUC
roc_obj_train <- roc(train$FRAUDE, train$predictions_train)
auc(roc_obj_train)
plot(1-roc_obj_train$specificities, roc_obj_train$sensitivities, 'l')



#7. Evaluation test. Lets try with our test data. As it's the first time we see 
#them we have to apply same steps as train.



test <- select(test,-id, -Canal1, -OFICINA_VIN, - HORA_AUX,-DIASEM,-DIAMES)


# antiquity of the client in years

test$FECHA_VIN <- as.Date(as.character(test$FECHA_VIN),
                           format = "%Y%m%d")
max_date <- as.Date(as.character(20150427),
                    format = "%Y%m%d") 

test$Antiguedad <- max_date-test$FECHA_VIN

test$Antiguedad <- as.integer(test$Antiguedad/365)

test <- select(test,-FECHA_VIN)

# Na as ceros

test$INGRESOS[is.na(test$INGRESOS)] <- 0
test$EGRESOS[is.na(test$EGRESOS)] <- 0
test$Dist_Sum_INTER[is.na(test$Dist_Sum_INTER)] <- 0
test$Dist_Mean_INTER[is.na(test$Dist_Mean_INTER)] <- 0
test$Dist_Max_INTER[is.na(test$Dist_Max_INTER)] <- 0
test$Dist_Mean_NAL[is.na(test$Dist_Mean_NAL)] <- 0
test$Antiguedad[is.na(test$Antiguedad)] <- 0

# Rows with Na "EDAD" are less than 20 so we delete them

test$EDAD[is.na(test$EDAD)] <- na.omit(test$EDAD)

# "SEXO" AND "SEGMENTO" MISSING VALUES

test$SEXO[test$SEXO == "" | test$SEXO == " "] <- NA
test$SEXO <- as.character(test$SEXO)
test$SEXO[is.na(test$SEXO)] <- "Sin determinar"
test$SEXO <- as.factor(test$SEXO)


test$SEGMENTO[test$SEGMENTO == "" | test$SEGMENTO == " "] <- NA
test$SEGMENTO <- as.character(test$SEGMENTO)
test$SEGMENTO[is.na(test$SEGMENTO)] <- "Sin determinar"
test$SEGMENTO <- as.factor(test$SEGMENTO)

#PREDICTIONS. BEST AIC MODEL_1

predictions_test <- predict(model_1,
                            newdata = test,
                            type = 'response')

test_Fraude <- cbind(test_Fraude, predictions_test)
head(test_Fraude)

test_Fraude$FRAUDE_predictions_test <- test_Fraude$predictions_test > 0.5 
test_Fraude$FRAUDE_predictions_test <- as.numeric(test_Fraude$FRAUDE_predictions_test)

# Confusion matrix
table(test_Fraude$FRAUDE_predictions_test, test_Fraude$FRAUDE)
round(prop.table(table(test_Fraude$FRAUDE_predictions_test, test_Fraude$FRAUDE)),2)


roc_obj_test <- roc(test_Fraude$FRAUDE, test_Fraude$FRAUDE_predictions_test)
auc(roc_obj_test)
plot(1-roc_obj_test$specificities, roc_obj_test$sensitivities, 'l')



