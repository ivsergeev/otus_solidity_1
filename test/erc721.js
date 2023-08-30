const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Otus ERC-721", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const tokenFactory = await ethers.getContractFactory("OtusERC721");
        const token = await tokenFactory.deploy();

        return { token, owner, addr1, addr2 };
        }

    it("Mint single token", async function () {
        const { token, owner , addr1 } = await loadFixture(deployTokenFixture);
        const tokenId = 1;

        await token.mint(addr1.address, tokenId);
        expect(await token.ownerOf(tokenId)).to.equal(addr1.address);
        expect(await token.balanceOf(addr1.address)).to.equal(1);
        });
});