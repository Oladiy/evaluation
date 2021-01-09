# **Project description**

Реализация выставления оценок жюри.

Инициатор деплоит контракт, в котором задает время на оценивание и раскрытие оценки, шкалу оценивания, 
имя, кого оценивают (beneficiary), адрес, куда будут переводиться деньги, и список адресов жюри. 

Во время evaluation-time жюри присылают хеш(оценка + nonce). Когда наступает reveal-time, жюри присылают значения, которые были захешированы. Если жюри проходит процедуру reveal, его голос идет в учет общей оценки.
Для жюри, которые не проходят процедуру reveal, предусмотрено наказание: во время refund у каждого, кто не прошел reveal, баланс уменьшается вдвое. Всем остальным на баланс возвращается депозит с вычетом результата оцениваемого, поделенного на количество жюри.

По итогу оценивания по адресу оцениваемого (beneficiary) отправляется сумма, равная среднему арифметическому от всех оценок.

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

Для запуска демонстрационного DApp запустите сервер

`nodejs dapp/evaluation.js`

И перейдите по по http://localhost:5002

# **Test** 

Запуск тестов на JavaScript и Solidity

`truffle test`
