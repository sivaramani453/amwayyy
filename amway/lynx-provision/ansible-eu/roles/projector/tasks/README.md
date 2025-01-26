# projector install magic explained

Unfortunatelly the projector install bash command does not provide passing additional arguments and it works in interactive mode.

By piping printf output with projector install, I can pass answers to interactive questions directly to projector. It works as long as the questions are not changed, so it's slicky, but I havent found another way for executing it.

* We need to accept license with y
* It asks which IDE we want to install, the choice is 1 (Idea Community)
* It asks if we want to choose only from projector-tested versions, we say yes
* Lastly, we choose exact version we want to get there, and we say 4

Obviously we may choose whatever we want to get there, those printed here are just defaults.

If you want to see full list of possible parameters, please run projector install on your machine, and write down whatever suits you. Then just simply apply those values to respective variables that are specified in default vars.