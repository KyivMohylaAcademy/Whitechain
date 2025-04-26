import { ethers } from "hardhat";
import { expect } from "chai";

describe("Web3Auth", () => {
  let auth: any;
  let user: any;
  let anotherUser: any;

  beforeEach(async () => {
    [user, anotherUser] = await ethers.getSigners();
    const Auth = await ethers.getContractFactory("Auth");
    auth = await Auth.deploy();
    await auth.waitForDeployment();
  });

  it("Should authenticate user", async () => {
    await auth.connect(user).authenticate();
    expect(await auth.isAuth(user.address)).to.equal(true);
  });

  it("Should fail if user is already authenticated", async () => {
    // First authentication attempt (should succeed)
    await auth.connect(user).authenticate();
    // Second authentication attempt (should fail)
    await expect(auth.connect(user).authenticate()).to.be.revertedWith("Already authenticated");
  });

  it("Should not authenticate a different user", async () => {
    // User 1 authenticates
    await auth.connect(user).authenticate();
    // User 2 tries to authenticate and should succeed
    await auth.connect(anotherUser).authenticate();
    expect(await auth.isAuth(anotherUser.address)).to.equal(true);
    // User 1 remains authenticated
    expect(await auth.isAuth(user.address)).to.equal(true);
  });

  it("Should not affect the authentication of other users", async () => {
    // Authenticate user 1
    await auth.connect(user).authenticate();
    expect(await auth.isAuth(user.address)).to.equal(true);

    // Authenticate user 2
    await auth.connect(anotherUser).authenticate();
    expect(await auth.isAuth(anotherUser.address)).to.equal(true);

    // Ensure that user 1 and user 2 have independent authentication statuses
    expect(await auth.isAuth(user.address)).to.equal(true);
    expect(await auth.isAuth(anotherUser.address)).to.equal(true);
  });

  it("Should allow multiple different users to authenticate independently", async () => {
    // User 1 authenticates
    await auth.connect(user).authenticate();
    expect(await auth.isAuth(user.address)).to.equal(true);
    
    // User 2 authenticates
    await auth.connect(anotherUser).authenticate();
    expect(await auth.isAuth(anotherUser.address)).to.equal(true);

    // Verify that both users are authenticated
    expect(await auth.isAuth(user.address)).to.equal(true);
    expect(await auth.isAuth(anotherUser.address)).to.equal(true);
  });
});
