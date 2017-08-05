# EARS - RMCAB & IRA_DAILY

setwd("/Users/qiqemtz/Documents/Epidemiology/source/RScripts_Epidemiology_Rmcab/")

source("ETL_RMCAB_IRA.R")

###################################################
# Small helper function to combine several equally long univariate sts objects
combineSTS <- function(stsList) {
  epoch <- as.numeric(epoch(stsList[[1]]))
  observed <- NULL
  alarm <- NULL
  for (i in 1:length(stsList)) {
    observed <- cbind(observed,observed(stsList[[i]]))
    alarm <- cbind(alarm,alarms(stsList[[i]]))
  }
  colnames(observed) <- colnames(alarm) <- names(stsList)
  res <- new("sts", epoch=as.numeric(epoch),
             observed=observed, alarm=alarm,epochAsDate=TRUE)
  return(res)
}
#################################################


###################################
#   RMCAB_IRA_DAILY               #
###################################

setEPS()
postscript("1 Test - RMCAB IRA DAILY.eps")

#mydata <- RMCAB_EP_ARANDA[RMCAB_EP_ARANDA$FECHA >= as.Date("2009-05-01") & RMCAB_EP_ARANDA$FECHA <= as.Date("2012-12-31"),]
ep.rmcab.sts <- new("sts", start = c(2009,1), freq = 52, observed = ira_weekly09_14$Casos)

plot(ep.rmcab.sts, xaxis.tickFreq = list(`%V` = atChange, `%m` = atChange,
                                            `%G` = atChange), xaxis.labelFreq = list(`%Y` = atMedian),
     xaxis.labelFormat = "%Y", type = observed ~ time)
dev.off()

#C3 EARS Algorithm
setEPS()
postscript("2 - Test EARS_C3 sobre IRA DAILY - RMCAB_IRA_DAILY.eps")
#inYears <- which(year(sispro.rips.sts)>(year(sispro.rips.sts[1])+4) )
inYears <- which(epoch(ep.rmcab.sts)>12)
control <- list(range = inYears, method = "C3", alpha = 0.05)
ep.rmcab.C3 <- earsC(ep.rmcab.sts, control = control)
plot(ep.rmcab.C3)
dev.off()

#C2 EARS Algorithm
setEPS()
postscript("3 - Test EARS_C2 sobre IRA DAILY - RMCAB_IRA_DAILY.eps")
#inYears <- which(year(sispro.rips.sts)>(year(sispro.rips.sts[1])+4) )
inYears <- which(epoch(ep.rmcab.sts)>12)
control <- list(range = inYears, method = "C2", alpha = 0.05)
ep.rmcab.C2 <- earsC(ep.rmcab.sts, control = control)
plot(ep.rmcab.C2)
dev.off()

#C1 EARS Algorithm
setEPS()
postscript("1 - Test EARS_C1 sobre IRA DAILY - RMCAB_IRA_DAILY.eps")
#inYears <- which(year(sispro.rips.sts)>(year(sispro.rips.sts[1])+4) )
inYears <- which(epoch(ep.rmcab.sts)>12)
control <- list(range = inYears, method = "C1", alpha = 0.05)
ep.rmcab.C1 <- earsC(ep.rmcab.sts, control = control)
plot(ep.rmcab.C1)
dev.off()

# Extract data from C1 C2 and C3 to export to python
C1_data_sts <- as.data.frame(ep.rmcab.C1)
C2_data_sts <- as.data.frame(ep.rmcab.C2)
C3_data_sts <- as.data.frame(ep.rmcab.C3)

#C1_exp_pred <- data.frame(C1_data_sts[c(6:277,280:285,290:370,371:375), c(1,5)])
#C2_exp_pred <- data.frame(C2_data_sts[c(6:277,280:285,290:375),c(1,5)])
#C3_exp_pred <- data.frame(C3_data_sts[c(6:277,280:285,290:375),c(1,5)])
#C1_exp_pred <- data.frame(C1_data_sts)
#C2_exp_pred <- data.frame(C2_data_sts)
#C3_exp_pred <- data.frame(C3_data_sts)


#C1_exp_pred <- data.frame(ira_daily_withdates$Start_Date,C1_exp_pred)
#C2_exp_pred <- data.frame(ira_daily_withdates$Start_Date,C2_exp_pred)
#C3_exp_pred <- data.frame(ira_daily_withdates$Start_Date,C3_exp_pred)

C1_exp_pred <- data.frame(ira_weekly09_14$Start_Date)
C2_exp_pred <- data.frame(ira_weekly09_14$Start_Date)
C3_exp_pred <- data.frame(ira_weekly09_14$Start_Date)


colnames(C1_exp_pred)[1] <- "Date"
colnames(C2_exp_pred)[1] <- "Date"
colnames(C3_exp_pred)[1] <- "Date"
#remove(C1_data_sts)

C1_data_sts <- data.frame(C1_data_sts$upperbound, C1_exp_pred[13:266,1])
colnames(C1_data_sts)[1] <- "upperbound"
colnames(C1_data_sts)[2] <- "Date"
#View(C1_data_sts)
C1_exp_pred <- merge(C1_exp_pred, C1_data_sts, by.x='Date', by.y='Date', all=TRUE)
C1_exp_pred <- data.frame(C1_exp_pred, ira_weekly09_14$Casos)
colnames(C1_exp_pred)[3] <- "observed"

C2_data_sts <- data.frame(C2_data_sts$upperbound, C2_exp_pred[13:266,1])
colnames(C2_data_sts)[1] <- "upperbound"
colnames(C2_data_sts)[2] <- "Date"
#View(C1_data_sts)
C2_exp_pred <- merge(C2_exp_pred, C2_data_sts, by.x='Date', by.y='Date', all=TRUE)
C2_exp_pred <- data.frame(C2_exp_pred, ira_weekly09_14$Casos)
colnames(C2_exp_pred)[3] <- "observed"

C3_data_sts <- data.frame(C3_data_sts$upperbound, C3_exp_pred[13:266,1])
colnames(C3_data_sts)[1] <- "upperbound"
colnames(C3_data_sts)[2] <- "Date"
#View(C1_data_sts)
C3_exp_pred <- merge(C3_exp_pred, C3_data_sts, by.x='Date', by.y='Date', all=TRUE)
C3_exp_pred <- data.frame(C3_exp_pred, ira_weekly09_14$Casos)
colnames(C3_exp_pred)[3] <- "observed"

write.csv(C1_exp_pred, "C1_exp_pred.csv", row.names = FALSE)
write.csv(C2_exp_pred, "C2_exp_pred.csv", row.names = FALSE)
write.csv(C3_exp_pred, "C3_exp_pred.csv", row.names = FALSE)
# C1, C2 and C3 EARS Algorithms

# inYears <- which(epoch(ep.rmcab.sts)>12)
# control <- list(range = inYears, method = "C1", alpha = 0.05)
# ep.rmcab.C1 <- earsC(ep.rmcab.sts, control = control)
# control <- list(range = inYears, method = "C2", alpha = 0.05)
# ep.rmcab.C2 <- earsC(ep.rmcab.sts, control = control)
# control <- list(range = inYears, method = "C3", alpha = 0.05)
# ep.rmcab.C3 <- earsC(ep.rmcab.sts, control = control)
# 
# 
# rips.surveillance <- combineSTS(list(EARS_C1=ep.rmcab.C1,
#                                      EARS_C2=ep.rmcab.C2,
#                                      EARS_C3=ep.rmcab.C3))
# 
# 
# setEPS()
# postscript("Test EARS C1.eps")
# #inYears <- which(year(sispro.rips.sts)>(year(sispro.rips.sts[1])+4) )
# plot(observed(ep.rmcab.C1), col="red", type="l")
# dev.off()


View(ira_weekly09_14)

fit.arima <- Arima(ep.rmcab.sts, c(5,1,0))
fit.arima <- arima(ep.rmcab.sts, order = c(5,1,0))

fit.arima <- Arima(ep.rmcab.sts, c(2,0,0))
fit.arima <- arima(ep.rmcab.sts, order = c(2,0,0))

fit.arima <- Arima(ep.rmcab.sts, c(3,0,2))
fit.arima <- arima(ep.rmcab.sts, order = c(3,0,2))

forecast.m <- forecast(fit.arima, h=100)

res <- residuals(fit.arima)
#par(mar = rep(2, 4))
tsdisplay(res)
#Box.test(res, lag=16, fitdf=4, type="Ljung")
View(res)
forecast.m$upper
plot(forecast.m)
summary(forecast(fit.arima, h=50))
summary(forecast(fit.arima, h=10))

ts_predicted <- data.frame(forecast.m$mean)
summary(forecast.m)
