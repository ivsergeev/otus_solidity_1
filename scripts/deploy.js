async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const token20 = await ethers.deployContract("OtusERC20");
    console.log("Token ERC-20 address:", await token20.getAddress());

    const token721 = await ethers.deployContract("OtusERC721");
    console.log("Token ERC-721 address:", await token721.getAddress());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });