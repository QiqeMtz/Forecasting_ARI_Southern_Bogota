library(RPostgreSQL)
library(surveillance)
library(EpiWeek)
library(tseries)
library(forecast)
library(seasonal)
library(fma)
options(tz="America/Bogota")

# Function to get data from database
# Conexion a la base RMCAB Final
con_db_rmcab <- dbConnect(PostgreSQL(), user="postgres", host="localhost", port=5432, dbname="rmcab_db_final")
con_db_epidemiology <- dbConnect(PostgreSQL(), user="postgres", host="localhost", port=5432, dbname="epidemiology_db")

# Dataset de valores RMCAB
rmcab_pte_aranda <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"RMCAB_PTE_ARANDA\"")
temp_pte_aranda <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"TEMP_PTE_ARANDA\"")

rmcab_kennedy <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"RMCAB_KENNEDY\"")
temp_kennedy <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"TEMP_KENNEDY\"")

rmcab_carvajal <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"RMCAB_CARVAJAL\"")
temp_carvajal <- dbGetQuery(con_db_rmcab, "SELECT * FROM \"TEMP_CARVAJAL\"")

# Dataset IRA_DAILY
ira_daily <- dbGetQuery(con_db_epidemiology, "SELECT * FROM \"IRA_DAILY_VIEW\"")

PTE_ARANDA <- merge(rmcab_pte_aranda, temp_pte_aranda, by=c("FECHA"), all = TRUE)
KENNEDY <- merge(rmcab_kennedy, temp_kennedy, by=c("FECHA"), all = TRUE)
CARVAJAL <- merge(rmcab_carvajal, temp_carvajal, by=c("FECHA"), all = TRUE)

#ira_monthly_dx <- dbGetQuery(con_db_epidemiology, "SELECT * FROM \"IRA_MONTHLY_BY_DX_VIEW\" WHERE \"COD_DX\" = 'J00X' OR \"COD_DX\" = 'J069' OR \"COD_DX\" = 'J029' OR \"COD_DX\" = 'J039' OR \"COD_DX\" = 'J209'")
ira_monthly_dx <- dbGetQuery(con_db_epidemiology, "SELECT * FROM \"IRA_MONTHLY_BY_DX_VIEW\"")

ira_weekly_dx <- dbGetQuery(con_db_epidemiology, "SELECT * FROM \"IRA_WEEKLY_BY_DX_VIEW\"")

#RMCAB_EP_ARANDA <- merge(ira_daily, PTE_ARANDA, by=c("FECHA"), all = TRUE)
#RMCAB_EP_KENNEDY <- merge(ira_daily, KENNEDY, by=c("FECHA"), all = TRUE)
#RMCAB_EP_CARVAJAL <- merge(ira_daily, CARVAJAL, by=c("FECHA"), all = TRUE)

dbDisconnect(con_db_rmcab)


# Small helper function to remove all datasets that won't be used in the future


setwd("/Users/qiqemtz/Documents/Epidemiology/source/RScripts_Epidemiology_Rmcab/")

# REPLACE '-9999' VALUES IN ALL RMCAB TABLES ****** REPLACED IN DATABASES(FINAL)

# PTE_ARANDA[PTE_ARANDA == -9999] <- NA
# CARVAJAL[CARVAJAL == -9999] <- NA
# KENNEDY[KENNEDY == -9999] <- NA
# temp_carvajal[temp_carvajal == -9999] <- NA
# temp_kennedy[temp_kennedy == -9999] <- NA
# temp_pte_aranda[temp_pte_aranda == -9999] <- NA

# GENERATE DATA BY STATION

#Precipitation data
car.prec <- data.frame(CARVAJAL$FECHA, CARVAJAL$PRECIPITACION)
ken.prec <- data.frame(KENNEDY$FECHA, KENNEDY$PRECIPITACION)
pte.prec <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$PRECIPITACION)
# PM 10 Data
car.pm10 <- data.frame(CARVAJAL$FECHA, CARVAJAL$PM_10)
ken.pm10 <- data.frame(KENNEDY$FECHA, KENNEDY$PM_10)
pte.pm10 <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$PM_10)
# PM 2.5 Data
car.pm25 <- data.frame(CARVAJAL$FECHA, CARVAJAL$PM_2.5)
ken.pm25 <- data.frame(KENNEDY$FECHA, KENNEDY$PM_2.5)
pte.pm25 <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$PM_2.5)
# NO2 Data
car.no2 <- data.frame(CARVAJAL$FECHA, CARVAJAL$NO2)
ken.no2 <- data.frame(KENNEDY$FECHA, KENNEDY$NO2)
pte.no2 <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$NO2)
# SO2 data
car.so2 <- data.frame(CARVAJAL$FECHA, CARVAJAL$SO2)
ken.so2 <- data.frame(KENNEDY$FECHA, KENNEDY$SO2)
pte.so2 <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$SO2)
# CO Data
car.co <- data.frame(CARVAJAL$FECHA, CARVAJAL$CO)
ken.co <- data.frame(KENNEDY$FECHA, KENNEDY$CO)
pte.co <- data.frame(PTE_ARANDA$FECHA, PTE_ARANDA$CO)
#Temperature data
car.temp <- temp_carvajal
ken.temp <- temp_kennedy
pte.temp <- temp_pte_aranda

# RENAME COLUMNS
#Rename *.FECHA in all DataFrames
#Precipitation data
colnames(car.prec)[1] <- "FECHA"
colnames(ken.prec)[1] <- "FECHA"
colnames(pte.prec)[1] <- "FECHA"
# PM 10 Data
colnames(car.pm10)[1] <- "FECHA"
colnames(ken.pm10)[1] <- "FECHA"
colnames(pte.pm10)[1] <- "FECHA"
# PM 2.5 Data
colnames(car.pm25)[1] <- "FECHA"
colnames(ken.pm25)[1] <- "FECHA"
colnames(pte.pm25)[1] <- "FECHA"
# NO2 Data
colnames(car.no2)[1] <- "FECHA"
colnames(ken.no2)[1] <- "FECHA"
colnames(pte.no2)[1] <- "FECHA"
# SO2 data
colnames(car.so2)[1] <- "FECHA"
colnames(ken.so2)[1] <- "FECHA"
colnames(pte.so2)[1] <- "FECHA"
# CO Data
colnames(car.co)[1] <- "FECHA"
colnames(ken.co)[1] <- "FECHA"
colnames(pte.co)[1] <- "FECHA"

#Rename *.values in all DataFrames
#Precipitation data
colnames(car.prec)[2] <- "PRECIPITACION"
colnames(ken.prec)[2] <- "PRECIPITACION"
colnames(pte.prec)[2] <- "PRECIPITACION"
# PM 10 Data
colnames(car.pm10)[2] <- "PM_10"
colnames(ken.pm10)[2] <- "PM_10"
colnames(pte.pm10)[2] <- "PM_10"
# PM 2.5 Data
colnames(car.pm25)[2] <- "PM_2.5"
colnames(ken.pm25)[2] <- "PM_2.5"
colnames(pte.pm25)[2] <- "PM_2.5"
# NO2 Data
colnames(car.no2)[2] <- "NO2"
colnames(ken.no2)[2] <- "NO2"
colnames(pte.no2)[2] <- "NO2"
# SO2 data
colnames(car.so2)[2] <- "SO2"
colnames(ken.so2)[2] <- "SO2"
colnames(pte.so2)[2] <- "SO2"
# CO Data
colnames(car.co)[2] <- "CO"
colnames(ken.co)[2] <- "CO"
colnames(pte.co)[2] <- "CO"

epi.data <- ira_daily
# CONVERT RIPS TO EPIWEEK
# =================== Setup epi.data (RIPS) to EpiWeek ===============================

epi.data$FECHA <- strptime(epi.data$FECHA, "%Y-%m-%d")

for (i in 1:length(epi.data$FECHA)) {
  epi.data$YEAR[i] <- dateToEpiweek(epi.data$FECHA[i])$year
  epi.data$WEEK[i] <- dateToEpiweek(epi.data$FECHA[i])$weekno
}

# print(length(epi.data$FECHA))
# ******** IS NOT WORKING, ADD WEEK NO. 53 OR 54 IN SOME YEARS (2009 I.E.)
# Convert column to time data type
# epi.data$FECHA <- strptime(epi.data$FECHA, "%Y-%m-%d")
# Year from fecha
# epi.data$YEAR <- dateToEpiweek(epi.data$FECHA, firstday = 'Sunday')$year
# Week from fecha
# epi.data$WEEK <- dateToEpiweek(epi.data$FECHA, firstday = 'Sunday')$weekno
# View(epi.data)

#epi.test <- data.frame(epi.data[c(200:248), 1])
#colnames(epi.test)[1] <- "Fecha"
#epi.test$YEAR <- dateToEpiweek(epi.data[c(200:248), 1])$year
#epi.test$WEEK <- dateToEpiweek(epi.data[c(200:248), 1])$weekno

#test <- data.frame(strptime(epi.data$FECHA, "%Y-%m-%d"))
#test$year <- dateToEpiweek(test)$year
#length(test[1,1])

# Aggregate by year and week (epi.data)
dd <- aggregate(epi.data$TOTAL, by=list(Year=epi.data$YEAR, Week=epi.data$WEEK), FUN=sum)
epi.data.week <- dd[order(dd[,1], dd[,2], na.last = TRUE),]
colnames(epi.data.week)[3] <- "Casos"

# *ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª epi data (ira weekly) *ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª*ª

ira_weekly09_14 <- data.frame(epi.data.week[1:266,])
ira_weekly14_16 <- data.frame(epi.data.week[272:355,])


# CONVERT RMCAB TO EPIWEEK
# =================== Setup carvajal data to EpiWeek =============================

# *************************** PRECIPITATION ****************************************
car.prec$FECHA <- strptime(car.prec$FECHA, "%Y-%m-%d")
# Year from fecha
#car.prec$YEAR <- dateToEpiweek(car.prec$FECHA)$year
# Week from fecha
#car.prec$WEEK <- dateToEpiweek(car.prec$FECHA)$weekno

for (i in 1:length(car.prec$FECHA)) {
  car.prec$YEAR[i] <- dateToEpiweek(car.prec$FECHA[i])$year
  car.prec$WEEK[i] <- dateToEpiweek(car.prec$FECHA[i])$weekno
}

#Aggregate by year and week
car.prec.min <- aggregate(car.prec$PRECIPITACION, by=list(Year=car.prec$YEAR, Week=car.prec$WEEK), FUN=min)
car.prec.max <- aggregate(car.prec$PRECIPITACION, by=list(Year=car.prec$YEAR, Week=car.prec$WEEK), FUN=max)
car.prec.prom <- aggregate(car.prec$PRECIPITACION, by=list(Year=car.prec$YEAR, Week=car.prec$WEEK), FUN=mean)

car.prec.min.week <- car.prec.min[order(car.prec.min[,1], car.prec.min[,2], na.last = TRUE),]
car.prec.max.week <- car.prec.max[order(car.prec.max[,1], car.prec.max[,2], na.last = TRUE),]
car.prec.prom.week <- car.prec.prom[order(car.prec.prom[,1], car.prec.prom[,2], na.last = TRUE),]

colnames(car.prec.min.week)[3] <- "PREC-MIN-CAR"
colnames(car.prec.max.week)[3] <- "PREC-MAX-CAR"
colnames(car.prec.prom.week)[3] <- "PREC-PROM-CAR"


# *************************** PM 10 ****************************************
car.pm10$FECHA <- strptime(car.pm10$FECHA, "%Y-%m-%d")
# Year from fecha
#car.pm10$YEAR <- dateToEpiweek(car.pm10$FECHA)$year
# Week from fecha
#car.pm10$WEEK <- dateToEpiweek(car.pm10$FECHA)$weekno
for (i in 1:length(car.pm10$FECHA)) {
  car.pm10$YEAR[i] <- dateToEpiweek(car.pm10$FECHA[i])$year
  car.pm10$WEEK[i] <- dateToEpiweek(car.pm10$FECHA[i])$weekno
}

#Aggregate by year and week
car.pm10.min <- aggregate(car.pm10$PM_10, by=list(Year=car.pm10$YEAR, Week=car.pm10$WEEK), FUN=min)
car.pm10.max <- aggregate(car.pm10$PM_10, by=list(Year=car.pm10$YEAR, Week=car.pm10$WEEK), FUN=max)
car.pm10.prom <- aggregate(car.pm10$PM_10, by=list(Year=car.pm10$YEAR, Week=car.pm10$WEEK), FUN=mean)

car.pm10.min.week <- car.pm10.min[order(car.pm10.min[,1], car.pm10.min[,2], na.last = TRUE),]
car.pm10.max.week <- car.pm10.max[order(car.pm10.max[,1], car.pm10.max[,2], na.last = TRUE),]
car.pm10.prom.week <- car.pm10.prom[order(car.pm10.prom[,1], car.pm10.prom[,2], na.last = TRUE),]

colnames(car.pm10.min.week)[3] <- "PM10-MIN-CAR"
colnames(car.pm10.max.week)[3] <- "PM10-MAX-CAR"
colnames(car.pm10.prom.week)[3] <- "PM10-PROM-CAR"


# *************************** PM 2.5 ****************************************
car.pm25$FECHA <- strptime(car.pm25$FECHA, "%Y-%m-%d")
# Year from fecha
#car.pm25$YEAR <- dateToEpiweek(car.pm25$FECHA)$year
# Week from fecha
#car.pm25$WEEK <- dateToEpiweek(car.pm25$FECHA)$weekno

for (i in 1:length(car.pm25$FECHA)) {
  car.pm25$YEAR[i] <- dateToEpiweek(car.pm25$FECHA[i])$year
  car.pm25$WEEK[i] <- dateToEpiweek(car.pm25$FECHA[i])$weekno
}

#Aggregate by year and week
car.pm25.min <- aggregate(car.pm25$PM_2.5, by=list(Year=car.pm25$YEAR, Week=car.pm25$WEEK), FUN=min)
car.pm25.max <- aggregate(car.pm25$PM_2.5, by=list(Year=car.pm25$YEAR, Week=car.pm25$WEEK), FUN=max)
car.pm25.prom <- aggregate(car.pm25$PM_2.5, by=list(Year=car.pm25$YEAR, Week=car.pm25$WEEK), FUN=mean)

car.pm25.min.week <- car.pm25.min[order(car.pm25.min[,1], car.pm25.min[,2], na.last = TRUE),]
car.pm25.max.week <- car.pm25.max[order(car.pm25.max[,1], car.pm25.max[,2], na.last = TRUE),]
car.pm25.prom.week <- car.pm25.prom[order(car.pm25.prom[,1], car.pm25.prom[,2], na.last = TRUE),]

colnames(car.pm25.min.week)[3] <- "PM2.5-MIN-CAR"
colnames(car.pm25.max.week)[3] <- "PM2.5-MAX-CAR"
colnames(car.pm25.prom.week)[3] <- "PM2.5-PROM-CAR"


# *************************** NO2 ****************************************
car.no2$FECHA <- strptime(car.no2$FECHA, "%Y-%m-%d")
# Year from fecha
#car.no2$YEAR <- dateToEpiweek(car.no2$FECHA)$year
# Week from fecha
#car.no2$WEEK <- dateToEpiweek(car.no2$FECHA)$weekno

for (i in 1:length(car.no2$FECHA)) {
  car.no2$YEAR[i] <- dateToEpiweek(car.no2$FECHA[i])$year
  car.no2$WEEK[i] <- dateToEpiweek(car.no2$FECHA[i])$weekno
}

#Aggregate by year and week
car.no2.min <- aggregate(car.no2$NO2, by=list(Year=car.no2$YEAR, Week=car.no2$WEEK), FUN=min)
car.no2.max <- aggregate(car.no2$NO2, by=list(Year=car.no2$YEAR, Week=car.no2$WEEK), FUN=max)
car.no2.prom <- aggregate(car.no2$NO2, by=list(Year=car.no2$YEAR, Week=car.no2$WEEK), FUN=mean)

car.no2.min.week <- car.no2.min[order(car.no2.min[,1], car.no2.min[,2], na.last = TRUE),]
car.no2.max.week <- car.no2.max[order(car.no2.max[,1], car.no2.max[,2], na.last = TRUE),]
car.no2.prom.week <- car.no2.prom[order(car.no2.prom[,1], car.no2.prom[,2], na.last = TRUE),]

colnames(car.no2.min.week)[3] <- "NO2-MIN-CAR"
colnames(car.no2.max.week)[3] <- "NO2-MAX-CAR"
colnames(car.no2.prom.week)[3] <- "NO2-PROM-CAR"

# *************************** SO2 ****************************************
car.so2$FECHA <- strptime(car.so2$FECHA, "%Y-%m-%d")
# Year from fecha
#car.so2$YEAR <- dateToEpiweek(car.so2$FECHA)$year
# Week from fecha
#car.so2$WEEK <- dateToEpiweek(car.so2$FECHA)$weekno

for (i in 1:length(car.so2$FECHA)) {
  car.so2$YEAR[i] <- dateToEpiweek(car.so2$FECHA[i])$year
  car.so2$WEEK[i] <- dateToEpiweek(car.so2$FECHA[i])$weekno
}


#Aggregate by year and week
car.so2.min <- aggregate(car.so2$SO2, by=list(Year=car.so2$YEAR, Week=car.so2$WEEK), FUN=min)
car.so2.max <- aggregate(car.so2$SO2, by=list(Year=car.so2$YEAR, Week=car.so2$WEEK), FUN=max)
car.so2.prom <- aggregate(car.so2$SO2, by=list(Year=car.so2$YEAR, Week=car.so2$WEEK), FUN=mean)

car.so2.min.week <- car.so2.min[order(car.so2.min[,1], car.so2.min[,2], na.last = TRUE),]
car.so2.max.week <- car.so2.max[order(car.so2.max[,1], car.so2.max[,2], na.last = TRUE),]
car.so2.prom.week <- car.so2.prom[order(car.so2.prom[,1], car.so2.prom[,2], na.last = TRUE),]

colnames(car.so2.min.week)[3] <- "SO2-MIN-CAR"
colnames(car.so2.max.week)[3] <- "SO2-MAX-CAR"
colnames(car.so2.prom.week)[3] <- "SO2-PROM-CAR"

# *************************** CO ****************************************
car.co$FECHA <- strptime(car.co$FECHA, "%Y-%m-%d")
# Year from fecha
#car.co$YEAR <- dateToEpiweek(car.co$FECHA)$year
# Week from fecha
#car.co$WEEK <- dateToEpiweek(car.co$FECHA)$weekno

for (i in 1:length(car.co$FECHA)) {
  car.co$YEAR[i] <- dateToEpiweek(car.co$FECHA[i])$year
  car.co$WEEK[i] <- dateToEpiweek(car.co$FECHA[i])$weekno
}

#Aggregate by year and week
car.co.min <- aggregate(car.co$CO, by=list(Year=car.co$YEAR, Week=car.co$WEEK), FUN=min)
car.co.max <- aggregate(car.co$CO, by=list(Year=car.co$YEAR, Week=car.co$WEEK), FUN=max)
car.co.prom <- aggregate(car.co$CO, by=list(Year=car.co$YEAR, Week=car.co$WEEK), FUN=mean)

car.co.min.week <- car.co.min[order(car.co.min[,1], car.co.min[,2], na.last = TRUE),]
car.co.max.week <- car.co.max[order(car.co.max[,1], car.co.max[,2], na.last = TRUE),]
car.co.prom.week <- car.co.prom[order(car.co.prom[,1], car.co.prom[,2], na.last = TRUE),]

colnames(car.co.min.week)[3] <- "CO-MIN-CAR"
colnames(car.co.max.week)[3] <- "CO-MAX-CAR"
colnames(car.co.prom.week)[3] <- "CO-PROM-CAR"

# *************************** TEMPERATURE ****************************************
car.temp$FECHA <- strptime(car.temp$FECHA, "%Y-%m-%d")
# Year from fecha
#car.temp$YEAR <- dateToEpiweek(car.temp$FECHA)$year
# Week from fecha
#car.temp$WEEK <- dateToEpiweek(car.temp$FECHA)$weekno

for (i in 1:length(car.temp$FECHA)) {
  car.temp$YEAR[i] <- dateToEpiweek(car.temp$FECHA[i])$year
  car.temp$WEEK[i] <- dateToEpiweek(car.temp$FECHA[i])$weekno
}

# Aggregate by year and week
car.temp.min <- aggregate(car.temp$T_MIN, by=list(Year=car.temp$YEAR, Week=car.temp$WEEK), FUN=mean)
car.temp.max <- aggregate(car.temp$T_MAX, by=list(Year=car.temp$YEAR, Week=car.temp$WEEK), FUN=mean)
car.temp.prom <- aggregate(car.temp$T_PROM, by=list(Year=car.temp$YEAR, Week=car.temp$WEEK), FUN=mean)

car.temp.min.week <- car.temp.min[order(car.temp.min[,1], car.temp.min[,2], na.last = TRUE),]
car.temp.max.week <- car.temp.max[order(car.temp.max[,1], car.temp.max[,2], na.last = TRUE),]
car.temp.prom.week <- car.temp.prom[order(car.temp.prom[,1], car.temp.prom[,2], na.last = TRUE),]

colnames(car.temp.min.week)[3] <- "T-MIN-CAR"
colnames(car.temp.max.week)[3] <- "T-MAX-CAR"
colnames(car.temp.prom.week)[3] <- "T-PROM-CAR"


# =================== Setup Kennedy data to EpiWeek =============================

# *************************** PRECIPITATION ****************************************
ken.prec$FECHA <- strptime(ken.prec$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.prec$YEAR <- dateToEpiweek(ken.prec$FECHA)$year
# Week from fecha
#ken.prec$WEEK <- dateToEpiweek(ken.prec$FECHA)$weekno

for (i in 1:length(ken.prec$FECHA)) {
  ken.prec$YEAR[i] <- dateToEpiweek(ken.prec$FECHA[i])$year
  ken.prec$WEEK[i] <- dateToEpiweek(ken.prec$FECHA[i])$weekno
}

#Aggregate by year and week
ken.prec.min <- aggregate(ken.prec$PRECIPITACION, by=list(Year=ken.prec$YEAR, Week=ken.prec$WEEK), FUN=min)
ken.prec.max <- aggregate(ken.prec$PRECIPITACION, by=list(Year=ken.prec$YEAR, Week=ken.prec$WEEK), FUN=max)
ken.prec.prom <- aggregate(ken.prec$PRECIPITACION, by=list(Year=ken.prec$YEAR, Week=ken.prec$WEEK), FUN=mean)

ken.prec.min.week <- ken.prec.min[order(ken.prec.min[,1], ken.prec.min[,2], na.last = TRUE),]
ken.prec.max.week <- ken.prec.max[order(ken.prec.max[,1], ken.prec.max[,2], na.last = TRUE),]
ken.prec.prom.week <- ken.prec.prom[order(ken.prec.prom[,1], ken.prec.prom[,2], na.last = TRUE),]

colnames(ken.prec.min.week)[3] <- "PREC-MIN-KEN"
colnames(ken.prec.max.week)[3] <- "PREC-MAX-KEN"
colnames(ken.prec.prom.week)[3] <- "PREC-PROM-KEN"


# *************************** PM 10 ****************************************
ken.pm10$FECHA <- strptime(ken.pm10$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.pm10$YEAR <- dateToEpiweek(ken.pm10$FECHA)$year
# Week from fecha
#ken.pm10$WEEK <- dateToEpiweek(ken.pm10$FECHA)$weekno

for (i in 1:length(ken.pm10$FECHA)) {
  ken.pm10$YEAR[i] <- dateToEpiweek(ken.pm10$FECHA[i])$year
  ken.pm10$WEEK[i] <- dateToEpiweek(ken.pm10$FECHA[i])$weekno
}

#Aggregate by year and week
ken.pm10.min <- aggregate(ken.pm10$PM_10, by=list(Year=ken.pm10$YEAR, Week=ken.pm10$WEEK), FUN=min)
ken.pm10.max <- aggregate(ken.pm10$PM_10, by=list(Year=ken.pm10$YEAR, Week=ken.pm10$WEEK), FUN=max)
ken.pm10.prom <- aggregate(ken.pm10$PM_10, by=list(Year=ken.pm10$YEAR, Week=ken.pm10$WEEK), FUN=mean)

ken.pm10.min.week <- ken.pm10.min[order(ken.pm10.min[,1], ken.pm10.min[,2], na.last = TRUE),]
ken.pm10.max.week <- ken.pm10.max[order(ken.pm10.max[,1], ken.pm10.max[,2], na.last = TRUE),]
ken.pm10.prom.week <- ken.pm10.prom[order(ken.pm10.prom[,1], ken.pm10.prom[,2], na.last = TRUE),]

colnames(ken.pm10.min.week)[3] <- "PM10-MIN-KEN"
colnames(ken.pm10.max.week)[3] <- "PM10-MAX-KEN"
colnames(ken.pm10.prom.week)[3] <- "PM10-PROM-KEN"


# *************************** PM 2.5 ****************************************
ken.pm25$FECHA <- strptime(ken.pm25$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.pm25$YEAR <- dateToEpiweek(ken.pm25$FECHA)$year
# Week from fecha
#ken.pm25$WEEK <- dateToEpiweek(ken.pm25$FECHA)$weekno

for (i in 1:length(ken.pm25$FECHA)) {
  ken.pm25$YEAR[i] <- dateToEpiweek(ken.pm25$FECHA[i])$year
  ken.pm25$WEEK[i] <- dateToEpiweek(ken.pm25$FECHA[i])$weekno
}

#Aggregate by year and week
ken.pm25.min <- aggregate(ken.pm25$PM_2.5, by=list(Year=ken.pm25$YEAR, Week=ken.pm25$WEEK), FUN=min)
ken.pm25.max <- aggregate(ken.pm25$PM_2.5, by=list(Year=ken.pm25$YEAR, Week=ken.pm25$WEEK), FUN=max)
ken.pm25.prom <- aggregate(ken.pm25$PM_2.5, by=list(Year=ken.pm25$YEAR, Week=ken.pm25$WEEK), FUN=mean)

ken.pm25.min.week <- ken.pm25.min[order(ken.pm25.min[,1], ken.pm25.min[,2], na.last = TRUE),]
ken.pm25.max.week <- ken.pm25.max[order(ken.pm25.max[,1], ken.pm25.max[,2], na.last = TRUE),]
ken.pm25.prom.week <- ken.pm25.prom[order(ken.pm25.prom[,1], ken.pm25.prom[,2], na.last = TRUE),]

colnames(ken.pm25.min.week)[3] <- "PM2.5-MIN-KEN"
colnames(ken.pm25.max.week)[3] <- "PM2.5-MAX-KEN"
colnames(ken.pm25.prom.week)[3] <- "PM2.5-PROM-KEN"


# *************************** NO2 ****************************************
ken.no2$FECHA <- strptime(ken.no2$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.no2$YEAR <- dateToEpiweek(ken.no2$FECHA)$year
# Week from fecha
#ken.no2$WEEK <- dateToEpiweek(ken.no2$FECHA)$weekno

for (i in 1:length(ken.no2$FECHA)) {
  ken.no2$YEAR[i] <- dateToEpiweek(ken.no2$FECHA[i])$year
  ken.no2$WEEK[i] <- dateToEpiweek(ken.no2$FECHA[i])$weekno
}

#Aggregate by year and week
ken.no2.min <- aggregate(ken.no2$NO2, by=list(Year=ken.no2$YEAR, Week=ken.no2$WEEK), FUN=min)
ken.no2.max <- aggregate(ken.no2$NO2, by=list(Year=ken.no2$YEAR, Week=ken.no2$WEEK), FUN=max)
ken.no2.prom <- aggregate(ken.no2$NO2, by=list(Year=ken.no2$YEAR, Week=ken.no2$WEEK), FUN=mean)

ken.no2.min.week <- ken.no2.min[order(ken.no2.min[,1], ken.no2.min[,2], na.last = TRUE),]
ken.no2.max.week <- ken.no2.max[order(ken.no2.max[,1], ken.no2.max[,2], na.last = TRUE),]
ken.no2.prom.week <- ken.no2.prom[order(ken.no2.prom[,1], ken.no2.prom[,2], na.last = TRUE),]

colnames(ken.no2.min.week)[3] <- "NO2-MIN-KEN"
colnames(ken.no2.max.week)[3] <- "NO2-MAX-KEN"
colnames(ken.no2.prom.week)[3] <- "NO2-PROM-KEN"

# *************************** SO2 ****************************************
ken.so2$FECHA <- strptime(ken.so2$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.so2$YEAR <- dateToEpiweek(ken.so2$FECHA)$year
# Week from fecha
#ken.so2$WEEK <- dateToEpiweek(ken.so2$FECHA)$weekno

for (i in 1:length(ken.so2$FECHA)) {
  ken.so2$YEAR[i] <- dateToEpiweek(ken.so2$FECHA[i])$year
  ken.so2$WEEK[i] <- dateToEpiweek(ken.so2$FECHA[i])$weekno
}

#Aggregate by year and week
ken.so2.min <- aggregate(ken.so2$SO2, by=list(Year=ken.so2$YEAR, Week=ken.so2$WEEK), FUN=min)
ken.so2.max <- aggregate(ken.so2$SO2, by=list(Year=ken.so2$YEAR, Week=ken.so2$WEEK), FUN=max)
ken.so2.prom <- aggregate(ken.so2$SO2, by=list(Year=ken.so2$YEAR, Week=ken.so2$WEEK), FUN=mean)

ken.so2.min.week <- ken.so2.min[order(ken.so2.min[,1], ken.so2.min[,2], na.last = TRUE),]
ken.so2.max.week <- ken.so2.max[order(ken.so2.max[,1], ken.so2.max[,2], na.last = TRUE),]
ken.so2.prom.week <- ken.so2.prom[order(ken.so2.prom[,1], ken.so2.prom[,2], na.last = TRUE),]

colnames(ken.so2.min.week)[3] <- "SO2-MIN-KEN"
colnames(ken.so2.max.week)[3] <- "SO2-MAX-KEN"
colnames(ken.so2.prom.week)[3] <- "SO2-PROM-KEN"

# *************************** CO ****************************************
ken.co$FECHA <- strptime(ken.co$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.co$YEAR <- dateToEpiweek(ken.co$FECHA)$year
# Week from fecha
#ken.co$WEEK <- dateToEpiweek(ken.co$FECHA)$weekno

for (i in 1:length(ken.co$FECHA)) {
  ken.co$YEAR[i] <- dateToEpiweek(ken.co$FECHA[i])$year
  ken.co$WEEK[i] <- dateToEpiweek(ken.co$FECHA[i])$weekno
}


#Aggregate by year and week
ken.co.min <- aggregate(ken.co$CO, by=list(Year=ken.co$YEAR, Week=ken.co$WEEK), FUN=min)
ken.co.max <- aggregate(ken.co$CO, by=list(Year=ken.co$YEAR, Week=ken.co$WEEK), FUN=max)
ken.co.prom <- aggregate(ken.co$CO, by=list(Year=ken.co$YEAR, Week=ken.co$WEEK), FUN=mean)

ken.co.min.week <- ken.co.min[order(ken.co.min[,1], ken.co.min[,2], na.last = TRUE),]
ken.co.max.week <- ken.co.max[order(ken.co.max[,1], ken.co.max[,2], na.last = TRUE),]
ken.co.prom.week <- ken.co.prom[order(ken.co.prom[,1], ken.co.prom[,2], na.last = TRUE),]

colnames(ken.co.min.week)[3] <- "CO-MIN-KEN"
colnames(ken.co.max.week)[3] <- "CO-MAX-KEN"
colnames(ken.co.prom.week)[3] <- "CO-PROM-KEN"

# *************************** TEMPERATURE ****************************************
ken.temp$FECHA <- strptime(ken.temp$FECHA, "%Y-%m-%d")
# Year from fecha
#ken.temp$YEAR <- dateToEpiweek(ken.temp$FECHA)$year
# Week from fecha
#ken.temp$WEEK <- dateToEpiweek(ken.temp$FECHA)$weekno

for (i in 1:length(ken.temp$FECHA)) {
  ken.temp$YEAR[i] <- dateToEpiweek(ken.temp$FECHA[i])$year
  ken.temp$WEEK[i] <- dateToEpiweek(ken.temp$FECHA[i])$weekno
}

# Aggregate by year and week
ken.temp.min <- aggregate(ken.temp$T_MIN, by=list(Year=ken.temp$YEAR, Week=ken.temp$WEEK), FUN=mean)
ken.temp.max <- aggregate(ken.temp$T_MAX, by=list(Year=ken.temp$YEAR, Week=ken.temp$WEEK), FUN=mean)
ken.temp.prom <- aggregate(ken.temp$T_PROM, by=list(Year=ken.temp$YEAR, Week=ken.temp$WEEK), FUN=mean)

ken.temp.min.week <- ken.temp.min[order(ken.temp.min[,1], ken.temp.min[,2], na.last = TRUE),]
ken.temp.max.week <- ken.temp.max[order(ken.temp.max[,1], ken.temp.max[,2], na.last = TRUE),]
ken.temp.prom.week <- ken.temp.prom[order(ken.temp.prom[,1], ken.temp.prom[,2], na.last = TRUE),]

colnames(ken.temp.min.week)[3] <- "T-MIN-KEN"
colnames(ken.temp.max.week)[3] <- "T-MAX-KEN"
colnames(ken.temp.prom.week)[3] <- "T-PROM-KEN"



# =================== Setup Puente Aranda data to EpiWeek =============================

# *************************** PRECIPITATION ****************************************
pte.prec$FECHA <- strptime(pte.prec$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.prec$YEAR <- dateToEpiweek(pte.prec$FECHA)$year
# Week from fecha
#pte.prec$WEEK <- dateToEpiweek(pte.prec$FECHA)$weekno

for (i in 1:length(pte.prec$FECHA)) {
  pte.prec$YEAR[i] <- dateToEpiweek(pte.prec$FECHA[i])$year
  pte.prec$WEEK[i] <- dateToEpiweek(pte.prec$FECHA[i])$weekno
}

#Aggregate by year and week
pte.prec.min <- aggregate(pte.prec$PRECIPITACION, by=list(Year=pte.prec$YEAR, Week=pte.prec$WEEK), FUN=min)
pte.prec.max <- aggregate(pte.prec$PRECIPITACION, by=list(Year=pte.prec$YEAR, Week=pte.prec$WEEK), FUN=max)
pte.prec.prom <- aggregate(pte.prec$PRECIPITACION, by=list(Year=pte.prec$YEAR, Week=pte.prec$WEEK), FUN=mean)

pte.prec.min.week <- pte.prec.min[order(pte.prec.min[,1], pte.prec.min[,2], na.last = TRUE),]
pte.prec.max.week <- pte.prec.max[order(pte.prec.max[,1], pte.prec.max[,2], na.last = TRUE),]
pte.prec.prom.week <- pte.prec.prom[order(pte.prec.prom[,1], pte.prec.prom[,2], na.last = TRUE),]

colnames(pte.prec.min.week)[3] <- "PREC-MIN-PTE"
colnames(pte.prec.max.week)[3] <- "PREC-MAX-PTE"
colnames(pte.prec.prom.week)[3] <- "PREC-PROM-PTE"


# *************************** PM 10 ****************************************
pte.pm10$FECHA <- strptime(pte.pm10$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.pm10$YEAR <- dateToEpiweek(pte.pm10$FECHA)$year
# Week from fecha
#pte.pm10$WEEK <- dateToEpiweek(pte.pm10$FECHA)$weekno

for (i in 1:length(pte.pm10$FECHA)) {
  pte.pm10$YEAR[i] <- dateToEpiweek(pte.pm10$FECHA[i])$year
  pte.pm10$WEEK[i] <- dateToEpiweek(pte.pm10$FECHA[i])$weekno
}

#Aggregate by year and week
pte.pm10.min <- aggregate(pte.pm10$PM_10, by=list(Year=pte.pm10$YEAR, Week=pte.pm10$WEEK), FUN=min)
pte.pm10.max <- aggregate(pte.pm10$PM_10, by=list(Year=pte.pm10$YEAR, Week=pte.pm10$WEEK), FUN=max)
pte.pm10.prom <- aggregate(pte.pm10$PM_10, by=list(Year=pte.pm10$YEAR, Week=pte.pm10$WEEK), FUN=mean)

pte.pm10.min.week <- pte.pm10.min[order(pte.pm10.min[,1], pte.pm10.min[,2], na.last = TRUE),]
pte.pm10.max.week <- pte.pm10.max[order(pte.pm10.max[,1], pte.pm10.max[,2], na.last = TRUE),]
pte.pm10.prom.week <- pte.pm10.prom[order(pte.pm10.prom[,1], pte.pm10.prom[,2], na.last = TRUE),]

colnames(pte.pm10.min.week)[3] <- "PM10-MIN-PTE"
colnames(pte.pm10.max.week)[3] <- "PM10-MAX-PTE"
colnames(pte.pm10.prom.week)[3] <- "PM10-PROM-PTE"


# *************************** PM 2.5 ****************************************
pte.pm25$FECHA <- strptime(pte.pm25$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.pm25$YEAR <- dateToEpiweek(pte.pm25$FECHA)$year
# Week from fecha
#pte.pm25$WEEK <- dateToEpiweek(pte.pm25$FECHA)$weekno

for (i in 1:length(pte.pm25$FECHA)) {
  pte.pm25$YEAR[i] <- dateToEpiweek(pte.pm25$FECHA[i])$year
  pte.pm25$WEEK[i] <- dateToEpiweek(pte.pm25$FECHA[i])$weekno
}

#Aggregate by year and week
pte.pm25.min <- aggregate(pte.pm25$PM_2.5, by=list(Year=pte.pm25$YEAR, Week=pte.pm25$WEEK), FUN=min)
pte.pm25.max <- aggregate(pte.pm25$PM_2.5, by=list(Year=pte.pm25$YEAR, Week=pte.pm25$WEEK), FUN=max)
pte.pm25.prom <- aggregate(pte.pm25$PM_2.5, by=list(Year=pte.pm25$YEAR, Week=pte.pm25$WEEK), FUN=mean)

pte.pm25.min.week <- pte.pm25.min[order(pte.pm25.min[,1], pte.pm25.min[,2], na.last = TRUE),]
pte.pm25.max.week <- pte.pm25.max[order(pte.pm25.max[,1], pte.pm25.max[,2], na.last = TRUE),]
pte.pm25.prom.week <- pte.pm25.prom[order(pte.pm25.prom[,1], pte.pm25.prom[,2], na.last = TRUE),]

colnames(pte.pm25.min.week)[3] <- "PM2.5-MIN-PTE"
colnames(pte.pm25.max.week)[3] <- "PM2.5-MAX-PTE"
colnames(pte.pm25.prom.week)[3] <- "PM2.5-PROM-PTE"


# *************************** NO2 ****************************************
pte.no2$FECHA <- strptime(pte.no2$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.no2$YEAR <- dateToEpiweek(pte.no2$FECHA)$year
# Week from fecha
#pte.no2$WEEK <- dateToEpiweek(pte.no2$FECHA)$weekno

for (i in 1:length(pte.no2$FECHA)) {
  pte.no2$YEAR[i] <- dateToEpiweek(pte.no2$FECHA[i])$year
  pte.no2$WEEK[i] <- dateToEpiweek(pte.no2$FECHA[i])$weekno
}


#Aggregate by year and week
pte.no2.min <- aggregate(pte.no2$NO2, by=list(Year=pte.no2$YEAR, Week=pte.no2$WEEK), FUN=min)
pte.no2.max <- aggregate(pte.no2$NO2, by=list(Year=pte.no2$YEAR, Week=pte.no2$WEEK), FUN=max)
pte.no2.prom <- aggregate(pte.no2$NO2, by=list(Year=pte.no2$YEAR, Week=pte.no2$WEEK), FUN=mean)

pte.no2.min.week <- pte.no2.min[order(pte.no2.min[,1], pte.no2.min[,2], na.last = TRUE),]
pte.no2.max.week <- pte.no2.max[order(pte.no2.max[,1], pte.no2.max[,2], na.last = TRUE),]
pte.no2.prom.week <- pte.no2.prom[order(pte.no2.prom[,1], pte.no2.prom[,2], na.last = TRUE),]

colnames(pte.no2.min.week)[3] <- "NO2-MIN-PTE"
colnames(pte.no2.max.week)[3] <- "NO2-MAX-PTE"
colnames(pte.no2.prom.week)[3] <- "NO2-PROM-PTE"

# *************************** SO2 ****************************************
pte.so2$FECHA <- strptime(pte.so2$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.so2$YEAR <- dateToEpiweek(pte.so2$FECHA)$year
# Week from fecha
#pte.so2$WEEK <- dateToEpiweek(pte.so2$FECHA)$weekno

for (i in 1:length(pte.so2$FECHA)) {
  pte.so2$YEAR[i] <- dateToEpiweek(pte.so2$FECHA[i])$year
  pte.so2$WEEK[i] <- dateToEpiweek(pte.so2$FECHA[i])$weekno
}

#Aggregate by year and week
pte.so2.min <- aggregate(pte.so2$SO2, by=list(Year=pte.so2$YEAR, Week=pte.so2$WEEK), FUN=min)
pte.so2.max <- aggregate(pte.so2$SO2, by=list(Year=pte.so2$YEAR, Week=pte.so2$WEEK), FUN=max)
pte.so2.prom <- aggregate(pte.so2$SO2, by=list(Year=pte.so2$YEAR, Week=pte.so2$WEEK), FUN=mean)

pte.so2.min.week <- pte.so2.min[order(pte.so2.min[,1], pte.so2.min[,2], na.last = TRUE),]
pte.so2.max.week <- pte.so2.max[order(pte.so2.max[,1], pte.so2.max[,2], na.last = TRUE),]
pte.so2.prom.week <- pte.so2.prom[order(pte.so2.prom[,1], pte.so2.prom[,2], na.last = TRUE),]

colnames(pte.so2.min.week)[3] <- "SO2-MIN-PTE"
colnames(pte.so2.max.week)[3] <- "SO2-MAX-PTE"
colnames(pte.so2.prom.week)[3] <- "SO2-PROM-PTE"

# *************************** CO ****************************************
pte.co$FECHA <- strptime(pte.co$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.co$YEAR <- dateToEpiweek(pte.co$FECHA)$year
# Week from fecha
#pte.co$WEEK <- dateToEpiweek(pte.co$FECHA)$weekno

for (i in 1:length(pte.co$FECHA)) {
  pte.co$YEAR[i] <- dateToEpiweek(pte.co$FECHA[i])$year
  pte.co$WEEK[i] <- dateToEpiweek(pte.co$FECHA[i])$weekno
}

#Aggregate by year and week
pte.co.min <- aggregate(pte.co$CO, by=list(Year=pte.co$YEAR, Week=pte.co$WEEK), FUN=min)
pte.co.max <- aggregate(pte.co$CO, by=list(Year=pte.co$YEAR, Week=pte.co$WEEK), FUN=max)
pte.co.prom <- aggregate(pte.co$CO, by=list(Year=pte.co$YEAR, Week=pte.co$WEEK), FUN=mean)

pte.co.min.week <- pte.co.min[order(pte.co.min[,1], pte.co.min[,2], na.last = TRUE),]
pte.co.max.week <- pte.co.max[order(pte.co.max[,1], pte.co.max[,2], na.last = TRUE),]
pte.co.prom.week <- pte.co.prom[order(pte.co.prom[,1], pte.co.prom[,2], na.last = TRUE),]

colnames(pte.co.min.week)[3] <- "CO-MIN-PTE"
colnames(pte.co.max.week)[3] <- "CO-MAX-PTE"
colnames(pte.co.prom.week)[3] <- "CO-PROM-PTE"

# *************************** TEMPERATURE ****************************************
pte.temp$FECHA <- strptime(pte.temp$FECHA, "%Y-%m-%d")
# Year from fecha
#pte.temp$YEAR <- dateToEpiweek(pte.temp$FECHA)$year
# Week from fecha
#pte.temp$WEEK <- dateToEpiweek(pte.temp$FECHA)$weekno

for (i in 1:length(pte.temp$FECHA)) {
  pte.temp$YEAR[i] <- dateToEpiweek(pte.temp$FECHA[i])$year
  pte.temp$WEEK[i] <- dateToEpiweek(pte.temp$FECHA[i])$weekno
}

# Aggregate by year and week
pte.temp.min <- aggregate(pte.temp$T_MIN, by=list(Year=pte.temp$YEAR, Week=pte.temp$WEEK), FUN=mean)
pte.temp.max <- aggregate(pte.temp$T_MAX, by=list(Year=pte.temp$YEAR, Week=pte.temp$WEEK), FUN=mean)
pte.temp.prom <- aggregate(pte.temp$T_PROM, by=list(Year=pte.temp$YEAR, Week=pte.temp$WEEK), FUN=mean)

pte.temp.min.week <- pte.temp.min[order(pte.temp.min[,1], pte.temp.min[,2], na.last = TRUE),]
pte.temp.max.week <- pte.temp.max[order(pte.temp.max[,1], pte.temp.max[,2], na.last = TRUE),]
pte.temp.prom.week <- pte.temp.prom[order(pte.temp.prom[,1], pte.temp.prom[,2], na.last = TRUE),]

colnames(pte.temp.min.week)[3] <- "T-MIN-PTE"
colnames(pte.temp.max.week)[3] <- "T-MAX-PTE"
colnames(pte.temp.prom.week)[3] <- "T-PROM-PTE"

# GENERATE RMCAB WITH IRA DATAFRAME
rmcab.dataset <- data.frame(car.co.min.week, car.co.max.week$`CO-MAX-CAR`, car.co.prom.week$`CO-PROM-CAR`,
                            car.no2.min.week$`NO2-MIN-CAR`, car.no2.max.week$`NO2-MAX-CAR`, car.no2.prom.week$`NO2-PROM-CAR`,
                            car.pm10.min.week$`PM10-MIN-CAR`, car.pm10.max.week$`PM10-MAX-CAR`, car.pm10.prom.week$`PM10-PROM-CAR`,
                            car.pm25.min.week$`PM2.5-MIN-CAR`, car.pm25.max.week$`PM2.5-MAX-CAR`, car.pm25.prom.week$`PM2.5-PROM-CAR`,
                            car.prec.min.week$`PREC-MIN-CAR`, car.prec.max.week$`PREC-MAX-CAR`, car.prec.prom.week$`PREC-PROM-CAR`,
                            car.so2.min.week$`SO2-MIN-CAR`, car.so2.max.week$`SO2-MAX-CAR`, car.so2.prom.week$`SO2-PROM-CAR`,
                            car.temp.min.week$`T-MIN-CAR`, car.temp.max.week$`T-MAX-CAR`, car.temp.prom.week$`T-PROM-CAR`,
                            ken.co.min.week$`CO-MIN-KEN`, ken.co.max.week$`CO-MAX-KEN`, ken.co.prom.week$`CO-PROM-KEN`,
                            ken.no2.min.week$`NO2-MIN-KEN`, ken.no2.max.week$`NO2-MAX-KEN`, ken.no2.prom.week$`NO2-PROM-KEN`,
                            ken.pm10.min.week$`PM10-MIN-KEN`, ken.pm10.max.week$`PM10-MAX-KEN`, ken.pm10.prom.week$`PM10-PROM-KEN`,
                            ken.pm25.min.week$`PM2.5-MIN-KEN`, ken.pm25.max.week$`PM2.5-MAX-KEN`, ken.pm25.prom.week$`PM2.5-PROM-KEN`,
                            ken.prec.min.week$`PREC-MIN-KEN`, ken.prec.max.week$`PREC-MAX-KEN`, ken.prec.prom.week$`PREC-PROM-KEN`,
                            ken.so2.min.week$`SO2-MIN-KEN`, ken.so2.max.week$`SO2-MAX-KEN`, ken.so2.prom.week$`SO2-PROM-KEN`,
                            ken.temp.min.week$`T-MIN-KEN`, ken.temp.max.week$`T-MAX-KEN`, ken.temp.prom.week$`T-PROM-KEN`,
                            pte.co.min.week$`CO-MIN-PTE`, pte.co.max.week$`CO-MAX-PTE`, pte.co.prom.week$`CO-PROM-PTE`,
                            pte.no2.min.week$`NO2-MIN-PTE`, pte.no2.max.week$`NO2-MAX-PTE`, pte.no2.prom.week$`NO2-PROM-PTE`,
                            pte.pm10.min.week$`PM10-MIN-PTE`, pte.pm10.max.week$`PM10-MAX-PTE`, pte.pm10.prom.week$`PM10-PROM-PTE`,
                            pte.pm25.min.week$`PM2.5-MIN-PTE`, pte.pm25.max.week$`PM2.5-MAX-PTE`, pte.pm25.prom.week$`PM2.5-PROM-PTE`,
                            pte.prec.min.week$`PREC-MIN-PTE`, pte.prec.max.week$`PREC-MAX-PTE`, pte.prec.prom.week$`PREC-PROM-PTE`,
                            pte.so2.min.week$`SO2-MIN-PTE`, pte.so2.max.week$`SO2-MAX-PTE`, pte.so2.prom.week$`SO2-PROM-PTE`,
                            pte.temp.min.week$`T-MIN-PTE`, pte.temp.max.week$`T-MAX-PTE`, pte.temp.prom.week$`T-PROM-PTE`)

epi.rmcab.dataset <- merge(rmcab.dataset, epi.data.week, by.x=c("Year", "Week"), by.y=c("Year", "Week"), all=TRUE)

#ira_weekly09_14 <- data.frame(epi.data.week[1:266,])
#ira_weekly14_16 <- data.frame(epi.data.week[272:355,])

# CREATE IRA DAILY DATASET WITH START DATE OF EPIWEEK
# Tried to create an ira_daily dataset with Start date of the epiweek, year and week no. with the number of cases

#ira_daily_withdates <- data.frame(epi.rmcab.dataset$Year, epi.rmcab.dataset$Week, epi.rmcab.dataset$Casos)
#colnames(ira_daily_withdates)[1] <- "Year"
#colnames(ira_daily_withdates)[2] <- "Week"
#colnames(ira_daily_withdates)[3] <- "Casos"

#**ira_daily_withdates$Start_Date <- epiweekToDate(ira_daily_withdates$Year, ira_daily_withdates$Week, firstday = 'Monday')$d0

#View(ira_daily_withdates)
#epiweekToDate(ira_daily_withdates$Year, ira_daily_withdates$Week, firstday = 'Monday')
# Until here ira_daily_withdates must work for anything (watch it)

# Now we create ira_daily_withdates with aggregate function, then whe extract the start date of that epiweek
#Aggregate by year and week
#ira_daily_withdates.agg <- aggregate(ira_daily_withdates$TOTAL, by=list(Year=ira_daily_withdates$YEAR, Week=ira_daily_withdates$WEEK), FUN=sum)
#ira_daily_withdates.week <- ira_daily_withdates.agg[order(ira_daily_withdates.agg[,1], ira_daily_withdates.agg[,2], na.last = TRUE),] 
#colnames(ira_daily_withdates.week)[3] <- "NUM_CASOS"
#View(ira_daily_withdates.week)
#ira_daily_withdates$Start_Date <- epiweekToDate(ira_daily_withdates$Year, ira_daily_withdates$Week)$d0
#i <- 1
for (i in 1:length(ira_weekly09_14$Year)) {
  #date_ <- epiweekToDate(ira_daily_withdates$Year[i], ira_daily_withdates$Week[i])$d0
  ira_weekly09_14$Start_Date[i] <- as.character(strptime(epiweekToDate(ira_weekly09_14$Year[i], ira_weekly09_14$Week[i])$d0, "%Y-%m-%d"))
  #print(epiweekToDate(ira_daily_withdates$Year[i], ira_daily_withdates$Week[i])$d0)
}
#strptime(pte.temp$FECHA, "%Y-%m-%d")
#test <- data.frame(epiweekToDate(ira_daily_withdates$Year[i], ira_daily_withdates$Week[i]))$d0
#View(ira_daily_withdates)
#View(epi.rmcab.dataset.wdate)

#garbageCollector()

#ira_weekly <- data.frame(ira_daily_withdates[18:379,])
#View(ira_weekly)
# Save data to csv

# Number of cases by week csv file
write.csv(ira_weekly09_14, "rips_rmcab_surveillance_09_14.csv", row.names = FALSE)


#IRA Monthly View
#View(ira_monthly_dx)
#dates <- data.frame(ira_daily_withdates$Start_Date)
#colnames(dates)[1] <- "FECHA"
#ira_monthly_dx_fixed <- data.frame(dates, ira_monthly_dx, by="FECHA", all=TRUE)

# Ira monthly until May 2014
ira_monthly_dx_09_14 <- data.frame(ira_monthly_dx[1:1674,])
ira_monthly_dx_14_16 <- data.frame(ira_monthly_dx[1700:2131,])

write.csv(ira_monthly_dx_09_14, "ira_monthly_dx_09_14.csv", row.names = FALSE)
write.csv(ira_monthly_dx_14_16, "ira_monthly_dx_14_16.csv", row.names = FALSE)


#View(ira_weekly_dx)
ira_weekly_dx_09_14 <- data.frame(ira_weekly_dx[1:4914,])
ira_weekly_dx_14_16 <- data.frame(ira_weekly_dx[4987:6286,])

write.csv(ira_weekly_dx_09_14, "ira_weekly_dx_09_14.csv", row.names = FALSE)
write.csv(ira_weekly_dx_14_16, "ira_weekly_dx_14_16.csv", row.names = FALSE)

#write.csv(ira_monthly_dx, "ira_monthly_dx.csv", row.names = FALSE)


remove(con_db_epidemiology, con_db_rmcab, PTE_ARANDA, KENNEDY, CARVAJAL, temp_carvajal, temp_kennedy, temp_pte_aranda)
remove(car.temp.prom.week, car.temp.max.week, car.temp.min.week, car.co.prom.week, car.co.max.week, car.co.min.week,
       car.no2.prom.week, car.no2.max.week, car.no2.min.week,car.so2.prom.week, car.so2.max.week, car.so2.min.week,
       car.pm25.prom.week, car.pm25.max.week, car.pm25.min.week,car.pm10.prom.week, car.pm10.max.week, car.pm10.min.week,
       car.prec.prom.week, car.prec.max.week, car.prec.min.week)
remove(ken.temp.prom.week, ken.temp.max.week, ken.temp.min.week, ken.co.prom.week, ken.co.max.week, ken.co.min.week,
       ken.no2.prom.week, ken.no2.max.week, ken.no2.min.week,ken.so2.prom.week, ken.so2.max.week, ken.so2.min.week,
       ken.pm25.prom.week, ken.pm25.max.week, ken.pm25.min.week,ken.pm10.prom.week, ken.pm10.max.week, ken.pm10.min.week,
       ken.prec.prom.week, ken.prec.max.week, ken.prec.min.week)
remove(pte.temp.prom.week, pte.temp.max.week, pte.temp.min.week, pte.co.prom.week, pte.co.max.week, pte.co.min.week,
       pte.no2.prom.week, pte.no2.max.week, pte.no2.min.week,pte.so2.prom.week, pte.so2.max.week, pte.so2.min.week,
       pte.pm25.prom.week, pte.pm25.max.week, pte.pm25.min.week,pte.pm10.prom.week, pte.pm10.max.week, pte.pm10.min.week,
       pte.prec.prom.week, pte.prec.max.week, pte.prec.min.week)
remove(car.temp.prom, car.temp.max, car.temp.min, car.co.prom, car.co.max, car.co.min,
       car.no2.prom, car.no2.max, car.no2.min,car.so2.prom, car.so2.max, car.so2.min,
       car.pm25.prom, car.pm25.max, car.pm25.min,car.pm10.prom, car.pm10.max, car.pm10.min,
       car.prec.prom, car.prec.max, car.prec.min)
remove(ken.temp.prom, ken.temp.max, ken.temp.min, ken.co.prom, ken.co.max, ken.co.min,
       ken.no2.prom, ken.no2.max, ken.no2.min,ken.so2.prom, ken.so2.max, ken.so2.min,
       ken.pm25.prom, ken.pm25.max, ken.pm25.min,ken.pm10.prom, ken.pm10.max, ken.pm10.min,
       ken.prec.prom, ken.prec.max, ken.prec.min)
remove(pte.temp.prom, pte.temp.max, pte.temp.min, pte.co.prom, pte.co.max, pte.co.min,
       pte.no2.prom, pte.no2.max, pte.no2.min,pte.so2.prom, pte.so2.max, pte.so2.min,
       pte.pm25.prom, pte.pm25.max, pte.pm25.min,pte.pm10.prom, pte.pm10.max, pte.pm10.min,
       pte.prec.prom, pte.prec.max, pte.prec.min)
remove(car.temp, car.temp, car.temp, car.co, car.co, car.co,
       car.no2, car.no2, car.no2,car.so2, car.so2, car.so2,
       car.pm25, car.pm25, car.pm25,car.pm10, car.pm10, car.pm10,
       car.prec, car.prec, car.prec)
remove(ken.temp, ken.temp, ken.temp, ken.co, ken.co, ken.co,
       ken.no2, ken.no2, ken.no2,ken.so2, ken.so2, ken.so2,
       ken.pm25, ken.pm25, ken.pm25,ken.pm10, ken.pm10, ken.pm10,
       ken.prec, ken.prec, ken.prec)
remove(pte.temp, pte.temp, pte.temp, pte.co, pte.co, pte.co,
       pte.no2, pte.no2, pte.no2,pte.so2, pte.so2, pte.so2,
       pte.pm25, pte.pm25, pte.pm25,pte.pm10, pte.pm10, pte.pm10,
       pte.prec, pte.prec, pte.prec)


ARI_series = read.csv("rips_rmcab_surveillance_09_14.csv")
# check if stationary
adf.test(ARI_series$Casos, k = trunc((length(ARI_series$Casos)-1)^(1/3)))

# check if seasonal
xS <- ts(ARI_series$Casos, frequency=365/7)
fit <- tbats(xS)
seasonal <- !is.null(fit$seasonal)
seasonal
fit

#fit <- auto.arima(ARI_series$Casos, stationary = TRUE, seasonal = TRUE)
fit <- auto.arima(ARI_series$Casos)
arimaorder(fit)

summary(ira_weekly_dx_09_14)

pie(ira_weekly_dx_09_14$TOTAL, ira_weekly_dx_09_14$COD_DX)

var <- summary(ira_weekly_dx_09_14)
summary.data.frame(ira_weekly_dx_09_14)

View(var)


# BACKUP TO RELATED WORK - 04 AUG 2017
write.csv(ira_daily, "BACKUP_ira_daily.csv", row.names = FALSE)
write.csv(epi.data.week, "BACKUP_ira_weekly.csv", row.names = FALSE)
write.csv(epi.rmcab.dataset, "BACKUP_rmcab_numberofcases_weekly.csv", row.names = FALSE)
write.csv(rmcab.dataset, "BACKUP_rmcab_weekly.csv", row.names = FALSE)
write.csv(CARVAJAL, "BACKUP_rmcab_carvajal_daily.csv", row.names = FALSE)
write.csv(KENNEDY, "BACKUP_rmcab_kennedy_daily.csv", row.names = FALSE)
write.csv(PTE_ARANDA, "BACKUP_rmcab_pte_aranda_daily.csv", row.names = FALSE)

RMCAB_DAILY <- merge(CARVAJAL, KENNEDY, by=c("FECHA"), all=TRUE)

colnames(RMCAB_DAILY)[2] <- "CARVAJAL_PRECIPITACION"
colnames(RMCAB_DAILY)[3] <- "CARVAJAL_PM10"
colnames(RMCAB_DAILY)[4] <- "CARVAJAL_PM2.5"
colnames(RMCAB_DAILY)[5] <- "CARVAJAL_NO2"
colnames(RMCAB_DAILY)[6] <- "CARVAJAL_SO2"
colnames(RMCAB_DAILY)[7] <- "CARVAJAL_CO"
colnames(RMCAB_DAILY)[8] <- "CARVAJAL_T_MIN"
colnames(RMCAB_DAILY)[9] <- "CARVAJAL_T_MAX"
colnames(RMCAB_DAILY)[10] <- "CARVAJAL_T_PROM"

colnames(RMCAB_DAILY)[11] <- "KENNEDY_PRECIPITACION"
colnames(RMCAB_DAILY)[12] <- "KENNEDY_PM10"
colnames(RMCAB_DAILY)[13] <- "KENNEDY_PM2.5"
colnames(RMCAB_DAILY)[14] <- "KENNEDY_NO2"
colnames(RMCAB_DAILY)[15] <- "KENNEDY_SO2"
colnames(RMCAB_DAILY)[16] <- "KENNEDY_CO"
colnames(RMCAB_DAILY)[17] <- "KENNEDY_T_MIN"
colnames(RMCAB_DAILY)[18] <- "KENNEDY_T_MAX"
colnames(RMCAB_DAILY)[19] <- "KENNEDY_T_PROM"

RMCAB_DAILY <- merge(RMCAB_DAILY, PTE_ARANDA, by=c("FECHA"), all=TRUE)

colnames(RMCAB_DAILY)[20] <- "PTE_ARANDA_PRECIPITACION"
colnames(RMCAB_DAILY)[21] <- "PTE_ARANDA_PM10"
colnames(RMCAB_DAILY)[22] <- "PTE_ARANDA_PM2.5"
colnames(RMCAB_DAILY)[23] <- "PTE_ARANDA_NO2"
colnames(RMCAB_DAILY)[24] <- "PTE_ARANDA_SO2"
colnames(RMCAB_DAILY)[25] <- "PTE_ARANDA_CO"
colnames(RMCAB_DAILY)[26] <- "PTE_ARANDA_T_MIN"
colnames(RMCAB_DAILY)[27] <- "PTE_ARANDA_T_MAX"
colnames(RMCAB_DAILY)[28] <- "PTE_ARANDA_T_PROM"

write.csv(RMCAB_DAILY, "BACKUP_rmcab_full_daily.csv", row.names = FALSE)
