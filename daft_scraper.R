# Capture Data from daft.ie
# Load libraries
library(rvest)
library(stringr)

property <- data.frame()
html <- read_html("http://www.daft.ie/cork-city/property-for-sale/")
cast <- html_nodes(html,".box") %>% 
    html_text(trim=TRUE) %>% ifelse(. == "", NA, .) 
nawhite <- str_trim(cast)
nawhite[1] <- paste("1. \n \n ", nawhite[1])
nawhite <- str_replace(nawhite, "-", "\n")
nawhite <- str_replace_all(nawhite, "\\|", "")
nawhite <- str_replace_all(nawhite, "Agent: ", "")
curr <- as.data.frame(str_split_fixed(nawhite, "\n", n = 50))
property <- rbind(property, curr)

stub <- c("http://www.daft.ie/cork-city/property-for-sale/?offset=")

# Get properties
i = 10
while(i < 100) {
    link <- paste(stub,i, sep = "")
    print(paste("Visiting Link: ", link))
    html <- read_html(link)
    cast <- html_nodes(html,".box") %>% 
        html_text(trim=TRUE) %>% ifelse(. == "", NA, .) 
    nawhite <- str_trim(cast)
    nawhite <- str_replace(nawhite, "-", "\n")
    nawhite <- str_replace_all(nawhite, "\\|", "")
    nawhite <- str_replace_all(nawhite, "Agent: ", "")
    curr <- as.data.frame(str_split_fixed(nawhite, "\n", n = 50))
    property <- rbind(property, curr)
    i <- i + 10
}

# Convert every cell to character type
property[] <- lapply(property, as.character)

# Trim white space to empty cells
property[] <- lapply(property, trimws)
# Replace empty cells with NA values
property[property==""] <- NA

# Replace un-needed values with na
for (i in 1:ncol(property)) {
    hits <- grep(pattern = "BER|     |Learn|Photos|Energy|scale|lower|Add", x = property[,i])
    property[,i][hits] <- NA
    i = i + 1 
}

# Delete every NA value, shifting cells to the left
property = as.data.frame(t(apply(property,1, function(x) { return(c(x[!is.na(x)],x[is.na(x)]) )} )))
# Convert every cell to character type
property[] <- lapply(property, as.character)

# Separate address
props <- separate(property, V2, c("AddressOne", "AddressTwo", "AddressThree", "AddressFour", "AddressFive", "AddressSix"), sep = ",", remove = TRUE, fill = "left")

# Remove id column
props$V1 <- NULL
colnames(props) <- c("AddressOne", "AddressTwo", "AddressThree", "AddressFour", "AddressFive", "AddressSix", "Type", "Photos", "Price", "Type2", "Beds", "Baths", "Other")
# Remove rows with all na's
prop <- props[rowSums(is.na(props)) != ncol(props),]

# Remove land and sites for sale
hits <- grep(pattern = "Site For Sale", x = prop$Type)
land <- prop[hits,]
homes <- prop[-hits,]

# Remove punctuation from price
homes$Price <- gsub(",|\u20AC", "", homes$Price)

# Remove rows with no price or wrongly formatted
hits <- grep(pattern = "[[:alpha:]]", x = homes$Price)
noPrice <- homes[hits,]
clean <- homes[-hits,]

# Shift cells right if number in type
#hits <- grep(pattern = "[[:digit:]]", x = clean$Type)

# Get price change details
hits <- grep(pattern = "[[:digit:]]", x = clean$Type2)

clean$priceChange <- NA

for(i in 1:length(hits)) {
    change <- clean$Type2[hits[i]]
    clean$Type2[hits[i]] <- NA
    clean[hits[i],10:(ncol(clean)-1)] <- clean[hits[i],11:ncol(clean)]
    clean$priceChange[hits[i]] <- change
}

# Clean up beds column
clean$Beds <- str_replace_all(clean$Beds, " Beds| Bed", "")

# Clean up baths column
clean$Baths <- str_replace_all(clean$Baths, " Baths|Bath", "")

# Remove bad text from baths column
hits <- grep(pattern = "[[:alpha:]]", x = clean$Baths)
clean$Baths[hits] <- NA

# Clean Type Column, shorten descriptions
clean$Type <- str_replace_all(clean$Type, " For Sale| House", "")

# Change column types
clean$AddressFive <- as.factor(clean$AddressFive)
clean$Type <- as.factor(clean$Type)
clean$Photos <- as.numeric(clean$Photos)
clean$Price <- as.numeric(clean$Price)
clean$Beds <- as.numeric(clean$Beds)
clean$Baths <- as.numeric(clean$Baths)

# Use decision tree to predict NA bathrooms    
Tree <- rpart(Baths ~ AddressFive + Price + Beds, 
                   data=clean[!is.na(clean$Baths),])

#Impute Predictions into dataset
clean$Baths[is.na(clean$Baths)] <- predict(Tree, clean[is.na(clean$Baths),])

# Clean price change column
clean$priceChange <- gsub(",|\u20AC", "", clean$priceChange)
clean$priceChange[is.na(clean$priceChange)] <- 0

# Remove duplicate type2 column
clean$Type2 <- NULL






# Keep clean columns for now
clean <- clean[,-c(13:54)]
clean$Baths <- round(clean$Baths,0)
change <- clean$Type2[hits[1]]
clean$Type2[hits[1]] <- NA
clean[hits[1],10:ncol(clean)] <- clean[hits[1],11:(ncol(clean)-1)]
clean$change[hits[1]] <- change


priceChange <- clean[hits,]
# Removed lines
# Fix first irregular entry
#nawhite[1] <- paste("1. \n \n ", nawhite[1])
#done <- gsub("[[:punct:]]", "", nawhite)

pho <- str_detect(property$V11, "Photos")
property$V4 <- str_replace(property$V4, "    ", "none")
property$V14 <- str_replace(property$V14, "What", "none")
property$V17 <- str_replace_all(property$V17, "property", "none")

commods_hits    <- grep(pattern = "BER", x = property$V14)
property$V14[commods_hits] <- NA
commods_subset  <- commods_df[,commods_hits]
commods_subset[,11] <- NULL # Remove AM gold price

fruit <- c("Apple|")
str_replace(fruit,"\\|","")
