const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Otus ERC-20", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const tokenFactory = await ethers.getContractFactory("OtusERC20");
        const token = await tokenFactory.deploy(1000000);

        return { token, owner, addr1, addr2 };
        }

    it("Should assign the total supply of tokens to the owner", async function () {
        const { token, owner } = await loadFixture(deployTokenFixture);
    
        const ownerBalance = await token.balanceOf(owner.address);
        expect(await token.totalSupply()).to.equal(ownerBalance);
        });
});