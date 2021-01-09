const express = require('express');
const ContractMeta = require('./ContractMeta');
const Web3 = require('web3');

const app = express();

// Создаем проект на INFURA
// И устанавливаем соединение в тестовой сети, указав ссылку на созданный проект
const ethNetwork = 'https://rinkeby.infura.io/v3/4bd54433f50140e291db1b47cce3cb94';
const web3 = new Web3(new Web3.providers.HttpProvider(ethNetwork));

// Задаем адрес задеплоенного контракта
const contractAddress = ContractMeta.Address;
const ABI = ContractMeta.ABI;

const contract = new web3.eth.Contract(ABI, contractAddress);

app.get('/', async (request, response) => {
    response.sendFile(`${__dirname}/templates/index.html`);
});

app.get('/jury/', async (request, response) => {
    response.sendFile(`${__dirname}/templates/not_jury.html`);
});

app.get('/spectator/', async (request, response) => {
    if (request.query['request'] === 'owner') {
        const owner = await getContractOwner()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get owner: ${err}`);
                }
            });
        response.send(`${owner}`);
    }

    if (request.query['request'] === 'scale') {
        const scaleMaxValue = await getScaleMaxValue()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get scale max value: ${err}`);
                }
            });
        response.send(`${scaleMaxValue}`);
    }

    if (request.query['request'] === 'evaluation_end') {
        const isHappened = await isHappenedEvaluation()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get evaluation end: ${err}`);
                }
            });
        if (isHappened) {
            response.send('Evaluation time is ended');
        }

        response.send('Evaluation time is not ended');
    }

    if (request.query['request'] === 'reveal_end') {
        const isHappened = await isHappenedReveal()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get reveal end: ${err}`);
                }
            });
        if (isHappened) {
            response.send('Reveal time is ended');
        }

        response.send('Reveal time is not ended');
    }

    if (request.query['request'] === 'evaluation_ended') {
        const isEnded = await isEvaluationEnded()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get evaluation ended: ${err}`);
                }
            });
        if (isEnded) {
            response.send('Evaluation time is ended');
        }

        response.send('Evaluation is not ended');
    }

    if (request.query['request'] === 'juries_amount') {
        const juriesAmount = await getJuriesAmount()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get juries amount: ${err}`);
                }
            });
        response.send(`${juriesAmount}`);
    }

    if (request.query['request'] === 'evaluation_sum') {
        const evaluationSum = await getEvaluationSum()
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get evaluation sum: ${err}`);
                }
            });
        response.send(`${evaluationSum}`);
    }

    if (request.query['address']) {
        const isUserJury = await isJury(request.query['address'])
            .catch((err) => {
                if (err) {
                    response.send(`Failed to get juries: ${err}`);
                }
            });
        if (isUserJury) {
            response.send(`Address ${request.query['address']} belongs to jury list`);
        }

        response.send(`Address ${request.query['address']} doesn't belong to jury list`);
    }

    response.sendFile(`${__dirname}/templates/spectator.html`);
});

async function getContractOwner() {
    return await contract.methods.owner().call();
}

async function getScaleMaxValue() {
    return await contract.methods.scaleMaxValue().call();
}

async function isHappenedEvaluation() {
    const evaluationEnd = await contract.methods.evaluationEnd().call();
    return await contract.methods.isHappened(evaluationEnd).call();
}

async function isHappenedReveal() {
    const revealEnd = await contract.methods.revealEnd().call();
    return await contract.methods.isHappened(revealEnd).call();
}

async function isEvaluationEnded() {
    return await contract.methods.evaluationEnded().call();
}

async function getJuriesAmount() {
    return await contract.methods.juriesAmount().call();
}

async function isJury(jury) {
    return await contract.methods.juries(jury).call();
}

async function getEvaluationSum() {
    return await contract.methods.evaluationSum().call();
}

// TODO for jury
// login as jury
// evaluate
// reveal
// endEvaluation


const server = app.listen(5002, () => {
    const port = server.address().port;

    console.log(`Server is running at localhost:${port}`);
});
