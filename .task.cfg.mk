PRINT_VARS = IMAGE VERSION TAG
PHONIFY = true
GOAL_STYLE = b_red
-include .task.mk
$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v23.1.2/task.mk -o .task.mk)

h help: vars
