# NICAR 2014 INTRO TO R
# R script
# For more on learning R, see

# The Computerworld Beginner's Guide to R
# http://bit.ly/RGuideIntro

# 4 data wrangling tasks in R
# http://bit.ly/RDataTasks

# 60+ Resources to Improve Your R Skills
# http://bit.ly/Rresources

# These first 4 lines are just if I want to compile to HTML - sets a better width/height for any plots
#+ setup, include=FALSE
library(knitr)
opts_chunk$set(fig.width = 10, fig.height = 6)
#' Now go on to write the rest of your code

# Test the interactive console: Enter a calculation
7 * 8

# load lattice package with some sample data included
library(lattice)

# See the melanoma data set
melanoma

# See all available data sets:
data()

# Create a plot with one line of code:
plot(melanoma)

# Try plotting another data set:
plot(women)

# Find out more about the data set:
help(women)

# Calculate a regression line
regline <- lm(melanoma$incidence ~ melanoma$year)

# add regression line to open plot
abline(regline)


# See correlations
cor(melanoma)

# store the value 5 in x using the R assignment operator <-
x <- 5

# if you really really hate the <- assignment operator, you can usually use =
x = 5

# Store a few values in x
x <- c(53, 42, 8, 7)

# Check the value of x again
x

# Access the first item in x - note that item #1 is index 1 NOT index 0 as in many other languages
x[1]

# Multiply all items in x (without saving into x). No for loop needed
x * 10

# Get some stats from x

mean(x)
median(x)
summary(x)

# Find the structure of an object with str() - in this case the structure of melanoma
str(melanoma)

# Just see what class it is
class(melanoma)

# Just see the column names
names(melanoma)

# See the dimensions: returns number of rows and columns
dim(melanoma)

# Load in the psych package to see an example of how easy it is to get stats with R
library(psych)
describe(melanoma)

# Digression: describeBy function using another sample data set, ChickWeight

# Here's what the data set structure looks like
str(ChickWeight)

# Here are the first few rows
head(ChickWeight)

# And here are a whole bunch of statistics by Diet group using describeBy

describeBy(ChickWeight, ChickWeight$Diet)


# See the first few and lat few rows of melanoma

head(melanoma)
tail(melanoma)

# See row 5, columns 2
melanoma[5,2]

# See all of row 5
melanoma[5,] # remember that comma! leave it out and you'll get an error

# Pull just a column with dollar sign notation
melanoma$incidence

# Combine dollar sign and bracket notation to see the first three items of a column:
melanoma$incidence[c(1,2,3)]
  # or
melanoma$incidence[1:3]

# Subset a data frame by certain logical criteria

melanoma[melanoma$incidence > 4,]
  # or
subset(melanoma, incidence > 4)

# Useful new way to work with data frames - the dplyr package
library(dplyr)

# filter the data frame by a logical criteria - similar syntax to subset
filter(melanoma, incidence > 4)

# Store the filtered results in variable melanoma.subset:
melanoma.subset <- filter(melanoma, incidence > 4)

# Type the first few letters of the variable name and hit tab, and you'll get a selection of available variables and functions:

mel

# How to get help about a function
help(plot)
# or
?plot

# See examples of using the function
example(plot)

# Just see arguments that a function takes:
args(plot)


#################### choroplethr, rCharts & quantmod packages ################################
library(choroplethr)

##### NOTE: To do this on your own system, you need to get a Census API key at
#### http://www.census.gov/developers/tos/key_request.html
#### Load the acs package and then install your key with
# library(acs)
# api.key.install('your census api key')


# Map per-capita income by US county using American Community Survey table B19301

choroplethr_acs(tableId="B19301", lod="county")

# Change to state
choroplethr_acs(tableId="B19301", lod="state")


# Here is how to create more Webby graphics where you can mouseover to get more details
library(rCharts)

hPlot(x="year", y="incidence", data = melanoma, type = 'scatter')
hPlot(x="height", y="weight", data = women, type = 'column')

# Here's a package designed for finance


library(quantmod)
getSymbols("TWTR",src="yahoo") 
barChart(TWTR)


#################### baltimore salaries #################################
# What is the current working directory?
getwd()


##### Need to set the working directory to the proper directory with the setwd() function

# Use read.csv() function to import salary data into an object called salaries
salaries <- read.csv("Baltimore_City_Employee_Salaries_FY2012.csv", header=TRUE, strip.white = TRUE)

# What's the structure of this?
str(salaries)

# The dollar sign isn't a numeric character, so R thinks this is a category and not a number.
# Fix that:

salaries$annual <- as.numeric(sub("\\$","", salaries$AnnualSalary))
salaries$gross <- as.numeric(sub("\\$","", salaries$GrossPay))

# add a column with date of hire as a date and not a "factor" or character string
salaries$startDate <- as.Date(salaries$HireDate, format="%m/%d/%Y")

# add a column for length of service: - data end date minus start date
salaries$lengthService <- as.Date("2012-06-30") - salaries$startDate

# what does that look like?
str(salaries)

# get that in years, not days
salaries$lengthService <- as.numeric(round(salaries$lengthService/365, 1))

str(salaries)

head(salaries)


# difference between gross pay and annual pay
salaries$diff <- salaries$gross - salaries$annual

# new data frame to work on without the names and character and factors for annual and gross pay
sals <- subset(salaries, select=-c(name, HireDate, AnnualSalary, GrossPay))


summary(sals)

# load the useful package doBy
library(doBy)

# See lowest gross
head(orderBy(~gross, sals))

salaries[11529,]

# See highest difference between annual and gross
tail(orderBy(~diff, sals))

#See how many in each agency

table(salaries$Agency)

# turn that into a data frame we can use
numEmployees <- as.data.frame(table(sals$Agency))
numEmployees <- orderBy(~-Freq, numEmployees)

# Rename the columns
names(numEmployees) <- c("Agency", "paidEmployees")

# look at that
numEmployees

# what's the median difference between gross and annual salary by department?
diffs <- summaryBy(diff ~ Agency, data=sals, FUN=median)
orderBy(~-diff.median, diffs)

# what's the median gross pay by agency?
medDept <- summaryBy(gross ~ Agency, data=sals, FUN=median)
medDept <- orderBy(~-gross.median, data=medDept)

# look at that
medDept

# and median annual pay
medDeptAnnual <- summaryBy(annual ~ Agency, data=sals, FUN=median)
medDeptAnnual <- orderBy(~annual.median, data=medDeptAnnual)


# Put it all together
summariesAnnual <- summaryBy(annual ~ Agency, data=sals, FUN=c(median, mean, min, max))

mySummaries <- summaryBy(annual + gross ~ Agency, data=sals, FUN=c(median, mean, min, max))

# If you like this better ... just announced last month, the dplyr package.
# Hadley Wickham, who taught the intermediate R class here last year.

library(dplyr)

# Create a special data frame of class "grouped"
sals.grouped <- group_by(sals, Agency) 
sals.grouped.results <- dplyr::summarise(sals.grouped, medAnnual = median(annual), medGross = median(gross), maxAnnual = max(annual), maxGross = max(gross))

# OR CHAIN!
sals.grouped.results <- sals %.%
  group_by(Agency) %.%
  dplyr::summarise(medAnnual = median(annual), medGross = median(gross), maxAnnual = max(annual), maxGross = max(gross))


# Time for some visualizations!
# There are several packages that are very popular for dataviz, but we'll stick to base R here.
# Get help for absolute basic plot with
?plot


# Let's look just at the police
police <- subset(sals, Agency == "Police Department")

# Here's a plot of length of service by gross pay
plot(police$lengthService, police$gross)

# Calculate a regression line
regline <- lm(police$gross ~ police$lengthService)

# add regression line to open plot
abline(regline)

# and by annual pay
plot(police$lengthService, police$annual)
regline <- lm(police$annual ~ police$lengthService)
abline(regline)

summary(police)

# Compare police, fire & public works
fire <- subset(sals, Agency == "Fire Department")
dpw <- subset(sals, Agency == "DPW-Water & Waste Water") 

# Note we could create a data frame with all three departments using
depts3 <- subset(sals, Agency == "Police Department" | Agency == "Fire Department" | Agency == "DPW-Water & Waste Water")

# OR with dplyr
# depts3 <- filter(sals, Agency=="Police Department" | Agency == "Fire Department" | Agency == "DPW-Water & Waste Water")

# Box plot of the Police Dept only
boxplot(police$annual, horizontal=TRUE, main="Police Annual Salaries")

# Some of these were not demonstrated at session because of small screens and low resolution on workshop laptops.

# put 3 plots on the same screen
par(mfrow=c(3,1))
boxplot(police$annual, horizontal=TRUE, ylim=c(0,200000), main="Police Annual Salaries")
boxplot(fire$annual, horizontal=TRUE, ylim=c(0,200000), main="Fire Annual Salaries")
boxplot(dpw$annual, horizontal=TRUE, ylim=c(0,200000), main="DPW Annual Salaries")

#reset par
par(mfrow=c(1,1))

#or combine them all in one this way (las=1 just makes both axis labels horizontal)
boxplot(police$annual, fire$annual, dpw$annual, names=c("Police", "Fire", "DPW"), las=1)

# make it colorful
boxplot(police$annual, fire$annual, dpw$annual, names=c("Police", "Fire", "DPW"), las=1, col=c("blue", "red", "green"))

# Easy enough to type in the categories manually when there are 3, but what if there are more?
boxplot(annual ~ Agency, las=2, data=sals)


# Increased the bottom margin with the margin argument of the parameter function:
par(mar=c(12,4.1,3.1,2.1))

boxplot(annual ~ Agency, las=2, data=sals)


# Odd shape in the COMP-Real Estate where the median and lower quartile are the same:
sals[sals$Agency == "COMP-Real Estate",]

# order this subset:
orderBy(~annual, sals[sals$Agency == "COMP-Real Estate",])

# reset parameters to their default, which I happen to know is this:
par(mar=c(5.1,4.1,4.1,2.1))


# Histograms

hist(police$annual)
hist(police$annual, breaks=10)

hist(fire$annual)
hist(dpw$annual)

par(mfrow=c(1, 3))
hist(police$annual, xlim=c(0, 200000))
hist(fire$annual, xlim=c(0, 200000))
hist(fire$annual, xlim=c(0, 200000))

hist(police$annual, xlim=c(0, 200000), col="blue", las=1)
hist(fire$annual, xlim=c(0, 200000), col="red", las=1)
hist(fire$annual, xlim=c(0, 200000), col="dark green", las=1)


# Density plots
# http://flowingdata.com/2012/05/15/how-to-visualize-and-compare-distributions/

datavector <- list(police$annual, fire$annual, dpw$annual)
titlevector <- c("Police", "Fire", "DPW")

for (i in 1:3){
  d <- density(datavector[[i]])
  plot(d, type="n", main=titlevector[i], xlim=c(0,200000))
  polygon(d, col="red", border="gray")
}

# Ugh, scientific notation. Can get rid of that with
options(scipen=999)

# then re-run plot above
for (i in 1:3){
  d <- density(datavector[[i]])
  plot(d, type="n", main=titlevector[i], xlim=c(0,200000))
  polygon(d, col="red", border="gray")
}

#reset par
par(mfrow=c(1,1))


# Look at another package, ggplot2, just to see a sample of ggplot2 graphics
# This was taught at the ntermediate R NICAR session last year

library(ggplot2)

# a "quick plot" using the qplot command, which decides the colors for you

qplot(annual, data=depts3, geom="density", fill=Agency, alpha=I(.5), 
      main="Distribution of Salaries", xlab="Agency", 
      ylab="Density")

# and the more complex "grammar of graphics" ggplot function
ggplot(data=depts3, aes(x=annual, fill=Agency)) + geom_density(alpha=.5) +
  scale_fill_manual(values=c("green","red", "blue"))

# basic bar chart for mean annual salaries in these departments:
depts3.meanAnnual <- summaryBy(annual ~ Agency, data=depts3)
barplot(depts3.meanAnnual$annual.mean, names.arg = depts3.meanAnnual$Agency)

# customized bar chart - color scheme idea from lynda.com class
barplot(depts3.meanAnnual$annual.mean, names.arg = depts3.meanAnnual$Agency,
        las = 1,
        col = c("beige", "blanchedalmond","bisque1"),
        border = NA,
        ylim = c(0,70000),
        main = "Mean Annual Salaries by Department")

# This example uses Highcharts from rCharts for an interactive graph.
# Note that Highcharts costs $90 for a commercial license
# first let's round the annual means:
depts3.meanAnnual$annual.mean <- round(depts3.meanAnnual$annual.mean)


h3 <- hPlot(x="Agency", y="annual.mean", data =depts3.meanAnnual, type="column", title="Average Salary by Agency")
h3
h3$yAxis(min=0, title=list(enabled=FALSE))
h3
h3$tooltip(useHTML = T, formatter = "#! function() { return this.x + ': $' + this.y; } !#")
h3

