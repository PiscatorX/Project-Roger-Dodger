library(ggplot2)
library(dplyr)
library(broom)
library(ggpmisc)


model_performance <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/RF_model_performance.tsv", header = T)

head(model_performance)
lm_fit =  lm(y_pred ~ y_test, data = model_performance)

summary(lm_fit)

plot(lm_fit, 
     which  = 1, 
     caption = paste(paste(response_var, term,  sep = " ~ "),"(Residuals vs Fitted)"),
     cex.caption = 1.5,
     cex.axis = 1.75,
     cex.lab = 1.75,
     col = "blue",
     pch = 1,
     lwd = 2,
     sub.caption = "")

plot(lm_fit,
     which  = 2,
     caption = "", 
     main = paste(paste(response_var, term,  sep = " ~ "),"(Normal Q-Q plot)"), 
     cex.caption = 1.5,
     cex.axis = 1.65,
     cex.lab = 1.75,
     col = "red",
     pch = 1,
     lwd = 2,
     sub.caption = "")


#extract model data
(lm_metrics <- augment(lm_fit) %>% data.frame())

(lm_stats <- tidy(lm_fit))

ggplot(model_performance, aes(x = y_test, y = y_pred)) +
  geom_point(size = 1.75, color = "#00AFBB") + 
  geom_smooth(method = "lm", size = 1, formula = y ~ x) +      
  stat_poly_eq(formula = y ~ x, 
               aes(label =  paste(..eq.label.., stat(rr.label), stat(p.value.label), sep = "*\", \"*")), 
               size = 6, parse = TRUE, label.y = "top", label.x = "left") +
  ylab('Predicted Adsorption Capacity (mgS/g)') + 
  xlab('Experimental Adsorption Capacity (mgS/g)') +
   theme(panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text = element_text(size=18, colour = "black"),
        axis.title = element_text(size=18, colour = "black"),
        panel.border = element_rect(colour = "black", fill=NA, size=1))

ggsave("model_performance.pdf")

