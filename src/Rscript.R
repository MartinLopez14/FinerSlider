


attach(experiment_results)

library(tidyr)
install.packages("tidyr")


#mean time for each slidertype
mean_time <- aggregate(experiment_results$time ~ experiment_results$sliderType, experiment_results, mean)
print(mean_time)

#mean time for each combination
mean_time_combo <- aggregate(experiment_results$time ~ experiment_results$inputMethod + experiment_results$sliderType, experiment_results, mean)
print(mean_time_combo)


#all values
plot1data <- experiment_results[c(-1)]

#mean values
plotdata <- aggregate(plot1data, by=list(plot1data$inputMethod, plot1data$sliderType, plot1data$value), FUN=mean)

print(plot1data)

#change data to wide representation
t_test_data <- spread(experiment_results, sliderType, time)
#t test Finer vs Range
t.test(t_test_data$FinerSlider, t_test_data$rangeSlider)

#change data to wide rep for COMBINATION
t_test_data2 <- spread(t_test_data, t_test_data$inputMethod, time)
print(t_test_data2)

#plot(x=plotdata$time, y=plotdata$value,
#     xlab="Target Value", ylab="Time Taken", col = interaction(plotdata$sliderType, plotdata$inputMethod))
#legend(1, 95, legend=c(interaction(plotdata$sliderType, plotdata$inputMethod)))

