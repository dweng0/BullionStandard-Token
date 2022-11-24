import { Contract, Signer } from 'ethers'
import { ethers } from "hardhat";
import { TOKEN } from "../scripts/deploy";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import * as dotenv from 'dotenv';
dotenv.config();

export const WETH_ADDRESS = process.env.WETH_ADDRESS;
export const ZoXExchange = process.env.EXCHANGE;

describe("BullionStandardToken", function () {
    let bs: Contract;
    let owner: SignerWithAddress;
    let userOne: SignerWithAddress;
    let userTwo: SignerWithAddress;
    let userThree: SignerWithAddress;

    const deployContract =  async (contract: any) => { 
        const [_owner, one, two, three] = await ethers.getSigners();
        owner = _owner;
        userOne = one;
        userTwo = two;
        userThree = three;
        
        const Bull = await ethers.getContractFactory(TOKEN);
        if(!WETH_ADDRESS) {
            throw new Error('WETH_ADDRESS not set in .env file');
        }
        if(!ZoXExchange) {
            throw new Error('EXCHANGE not set in .env file');
        }
        
        bs = await Bull.deploy(WETH_ADDRESS, ZoXExchange);
        
    }

    beforeEach(deployContract);

    it("it should deploy", async () => {
        await bs.connect(owner).deployed();
    });
});
