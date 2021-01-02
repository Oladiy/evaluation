# **Project description**

Инициатор деплоит контракт, в котором задает шкалу голосования, имя, за кого голосуют, и адрес, куда будут переводиться деньги. 
В ходе голосования участники присылают хэш(оценка + nonce).
По итогу голосования вычисляется средняя оценка и сумма этой оценке, отправляется по адресу beneficiary. 

# **Install**

`npm install -g ganache-cli`

`git clone https://github.com/Oladiy/voting`

`npm install`

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
