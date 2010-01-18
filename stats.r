calc = function(name) {
  x <- read.csv(paste(name, '.time', sep = ''))
  a = mean(x)
  s = sd(x)
  cat(name, ': mean = ', a, ', stdev = ', s, '\n')
}

calc('C70')
calc('C70Tip1209')
calc('Static')
calc('Static1209')
calc('Stock')
calc('Stock1209')
calc('StockTip1209')

