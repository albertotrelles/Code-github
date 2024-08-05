library(openxlsx)
Dir = "C:/Users/ALBERTO TRELLES/Documents/Alberto/RA/Experimento lab"
Input = paste0(Dir, "/Input")
Output = paste0(Dir, "/Output")
setwd(Dir)

fileNames = list.files("Input")
for (file in fileNames){
  
  data = read.csv(paste0(Input, "/", file))
  nobs = dim(data)[1]
  nvars = dim(data)[2]
  questions = seq(1, 10, 1)
  answers = c(123, 2, 60, 2, 1200, 2, 1, 16109, 22, 4)
  
  pagos = c()
  for (i in 1:nobs) {
    
    suma=0
    for (n in 1:10) {
      quest_control = eval(parse(text = paste0("data$control.1.player.pregunta", n)))
      quest_treat = eval(parse(text = paste0("data$treat.1.player.pregunta", n)))
      
      if (quest_control[i] %in% answers[n]){
        suma=suma+1
      }
      if (quest_treat[i] %in% answers[n]){
        suma=suma+1
      }
      
    }
    pagos[i] = suma
    
  }
  
  correctas = pagos
  pagos = 5 + 0.5*pagos
  data = data.frame(pagos, correctas, data)
  
  write.csv(data, file = paste0(Output, "/pagos_", file))
  write.xlsx(data, file = paste0(Output, "/pagos_", substr(file, 1,nchar(file)-4), ".xlsx"))
  
}


