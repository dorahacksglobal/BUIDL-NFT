// usage: node sign.js <bid> <miner>

const Web3 = require('web3')
const secp256k1 = require('secp256k1')

// 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
const signerKey = new Uint8Array(32)
signerKey[31] = 1

function sign(bid, miner) {
  const msgHash = Web3.utils
    .keccak256(miner + Number(bid).toString(16).padStart(64, '0'))
    .substr(2)

  const msg = new Uint8Array(32)
  for (let i = 0; i < 32; i++) {
    msg[i] = Number('0x' + msgHash.substr(i * 2, 2))
  }

  const sign = secp256k1.ecdsaSign(msg, signerKey)
  let signature =
    '0x' +
    Array.prototype.map
      .call(sign.signature, (byte) => byte.toString(16).padStart(2, '0'))
      .join('')
  signature += (sign.recid + 27).toString(16)

  return signature
}

const bid = process.argv[2]
const miner = process.argv[3]
console.log(sign(bid, miner))
