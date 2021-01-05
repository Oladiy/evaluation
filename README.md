# **Project description**

Реализация выставления оценок комиссией.

Инициатор деплоит контракт, в котором задает время на оценивание, шкалу голосования, 
имя, за кого голосуют (beneficiary), адрес, куда будут переводиться деньги, и список адресов жюри. 
В ходе голосования жюри присылают оценку.
По итогу голосования по адресу beneficiary отправляется сумма, равная среднему арифметическому от всех оценок.

# **Install**

`npm install -g ganache-cli`

`git clone https://github.com/Oladiy/evaluation`

`cd evaluation`

`npm install`

`git clone https://github.com/abdk-consulting/abdk-libraries-solidity.git`

# **Build**

`truffle build`

# **Run**

Запустите в отдельном терминале

`ganache-cli`

Задеплойте контракт

`truffle deploy`

# **Test**
Запуск тестов на JavaScript и Solidity

`truffle test`
