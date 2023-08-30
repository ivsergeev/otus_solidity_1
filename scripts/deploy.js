async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const token20Factory = await ethers.getContractFactory("OtusERC20");
    const token20 = await token20Factory.deploy(1000000);
    console.log("Token ERC-20 address:", await token20.address);

    const token721Factory = await ethers.getContractFactory("OtusERC721");
    const token721 = await token721Factory.deploy();
    console.log("Token ERC-721 address:", await token721.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });