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

`cd contracts`

`git clone https://github.com/abdk-consulting/abdk-libraries-solidity.git`

# **Build**

`truffle build`

# **Run**

Запустите в отдельном терминале

`ganache-cli`

**Для успешного тестирования, при запуске ganache-cli необходимо взять из секции Available Accounts адрес (0) и добавить его в файл `migrations/2_deploy_contracts.js` на строку 13.**

Задеплойте контракт

`truffle deploy`

# **Test** 

Запуск тестов на JavaScript и Solidity

`truffle test`
