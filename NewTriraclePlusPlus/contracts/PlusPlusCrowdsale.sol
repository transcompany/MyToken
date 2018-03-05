pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        uint c = a / b;

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint;
    mapping (address => uint) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public  constant returns (uint balance) {
        return balances[_owner];
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint)) allowed;


    /**
      * @dev Transfer tokens from one address to another
      * @param _from address The address which you want to send tokens from
      * @param _to address The address which you want to transfer to
      * @param _value uint256 the amout of tokens to be transfered
      */
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint _value) public returns (bool) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
      * @dev Function to check the amount of tokens that an owner allowed to a spender.
      * @param _owner address The address which owns the funds.
      * @param _spender address The address which will spend the funds.
      * @return A uint256 specifing the amount of tokens still available for the spender.
      */
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}

/**
 * @title Mintable token   
 */
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint amount);

    event MintFinished();

    /**
     * @dev minting status
     */
    bool public mintingFinished = false;

    /**
     * @dev Check token can mint or not
     */
    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Mint token
     * @param _to receiver address
     * @param _amount amount of send value
     * Only owner can do this function
     * This can be done only when minting is not finish
     */
    function mint(address _to, uint _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
     * @dev Destroy (Burn) Token
     * @param _amount number of destroy tokens
     * @param destroyer who destroy the tokens
     * Only owner can do this function
     */
    function destroy(uint _amount, address destroyer) public onlyOwner {
        uint myBalance = balances[destroyer];
        if (myBalance > _amount) {
            totalSupply = totalSupply.sub(_amount);
            balances[destroyer] = myBalance.sub(_amount);
        }
        else {
            if (myBalance != 0) totalSupply = totalSupply.sub(myBalance);
            balances[destroyer] = 0;
        }
    }

    /**
     * @dev Finish miting 
     */
    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

contract TriracleToken is MintableToken {
    string public name;

    string public symbol;

    uint8 public decimals;

    uint public startTime;
    uint public endTime;

    modifier transferCheck() {
        if (block.timestamp >= startTime && block.timestamp < endTime) {
            require(msg.sender == owner);
        }
        _;
    }

    /**
     * @dev Contructor of token
     */
    function TriracleToken(uint _startTime, uint _endTime) public {
        name = "TPP ICO TOKEN SALE";
        symbol = "TPP";
        decimals = 18;
        startTime = _startTime;
        endTime = _endTime;
        mint(msg.sender, 20000000000000000000000000); // 20m token
    }

    /**
     * @dev overwrite transfer
     */
    function transfer(address to, uint value) public transferCheck returns (bool) {
        require(to != address(0x0));

        return super.transfer(to, value);
    }

    /**
     * @dev overwrite transferFrom
     */
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(to != address(0x0));
        require(block.timestamp >= endTime);

        return super.transferFrom(from, to, value);
    }
}

contract Crowdsale is Ownable {
    using SafeMath for uint;

    // use token for this address
    TriracleToken public token;
    // public address of wallet which receive ETH
    address public wallet;
    // amount of raised money
    uint public totalWeiRaised;
    // maximum amount can buy in wei
    uint public capLimit;
    // total wei each participant contribute
    mapping(address=>uint) public totalContribute;
    
    /**
     * @dev contructor for crowdsale
     */
    function Crowdsale() public {
        token = createToken();
        wallet = msg.sender;
        capLimit = 1000000000000000000; // 1 ETH = 10 ^ 6 tokens
    }

    /**
     * @dev create token for this contract
     */
    function createToken() internal returns (TriracleToken) {
        return new TriracleToken(startTime, endTime);
    }

    /**
     * @dev Set a new wallet
     * @param newWallet new wallet the fund will be send to
     */
    function setWallet(address newWallet) public onlyOwner {
        wallet = newWallet;
    }

    /**
     * @dev Forward fund to address
     * @param amount amount to be sent
     */
    function forwardFund(uint amount) internal {
        wallet.transfer(amount);
    }

    /**
     * @dev Refund to address
     */
    function refundExceed(address receiver, uint amount) internal {
        receiver.transfer(amount);
    }

    /**
     * @dev Check crowdsale is end
     */
    function hasEnd() public constant returns (bool) {
        return block.timestamp < startTime || block.timestamp >= endTime;
    }

    /**
     * @dev increase cap limit of tokens
     * @param amount amount increase
     */
    function increaseCapLimit(uint amount) public onlyOwner {
        capLimit.add(amount);
    }

    // 02/03/2018 12AM
    uint startTime = 1520215800;
    uint stage1 = startTime + 1 hours;
    uint endTime = stage1 + 1 hours;

    /**
     * @dev Fallback function to buy token
     */
    function () public payable {
        buyTokens(msg.sender);
    }

    /*
     * @dev check eligible of buyer
     * @param buyer address need to be checked
     */
    function eligibleCheck(address buyer) internal returns (uint) {
        if (block.timestamp < startTime) return 0;
        if (block.timestamp >= endTime) return 0;
        
        uint remainCap = capLimit.sub(totalContribute[buyer]);
        uint weiAmount = msg.value;
        if (remainCap < weiAmount) {
            return remainCap;
        }
        else {
            return weiAmount;
        }
    }

    /**
     * check if exceed balance limit then refund to buyer the exceeded
     * @dev Forward fund to addressins.token().then((dm) => {tkadd = dm})

     * @param benificary Who buy token
     */
    function buyTokens(address benificary) payable public returns (uint) {
        require(benificary != address(0x0));
        require(msg.value != 0);
        require(!hasEnd());

        uint weiAmount = eligibleCheck(msg.sender);
        uint tokenAmount;

        if (block.timestamp >= startTime && block.timestamp < stage1) {
            tokenAmount = weiAmount.mul(1200); // 20% bonus in stage1
        }
        else {
            tokenAmount = weiAmount.mul(1000);
        }

        if (msg.value > weiAmount) {
            refundExceed(msg.sender, msg.value.sub(weiAmount));
        }

        forwardFund(weiAmount);
        assert(token.transfer(benificary, weiAmount));
        totalWeiRaised = totalWeiRaised.add(weiAmount);
        totalContribute[msg.sender] = totalContribute[msg.sender].add(weiAmount);

        return weiAmount;
    }

    /**
     * @dev Destroy some token
     * @param amount Amount of destroyed token
     */
    function destroyToken(uint amount) public onlyOwner {
        token.destroy(amount.mul(1000000000000000000), msg.sender);
    }

    /**
     * @dev If someone send ETH or any token to this address
     * we can get it back
     * @param anyToken Token need to be drained
     */
    function drainERC20Token(ERC20 anyToken) public onlyOwner returns (bool) {
        require(hasEnd());

        if (this.balance > 0) {
            wallet.transfer(this.balance);
        }

        if (anyToken != address(0x0)) {
            assert(anyToken.transfer(owner, anyToken.balanceOf(this)));
        }        

        return true;
    }

    /**
     * @dev change the capacity limit each investor can buy
     * @param limit new limit
     */
    function setCapLimit(uint limit) public onlyOwner {
        capLimit = limit;
    }
}

contract TokenVault is Ownable {
    using SafeMath for uint;
    // the time when user can withdraw token
    uint public endTime = 1520230200;
    // total tokens of this contract
    uint public totalToken;
    // total token distributed
    uint public tokenDistributed;
    TriracleToken public token;
    // number of tokens investors have in this contract
    mapping(address=>uint) public holdingBalances;

    function TokenVault(TriracleToken _token) public {
        token = _token;
    }

    /*
     * @dev withdraw the money from withdrawer,
     * withdrawer must have more then amount to withdraw
     * @param amount amount to withdraw
     */
    function withdraw(uint amount) public returns (bool) {
        require(block.timestamp >= endTime);
        require(holdingBalances[msg.sender] != 0);

        if (amount > holdingBalances[msg.sender]) {
            if (holdingBalances[msg.sender] != 0) {
                assert(token.transfer(msg.sender, holdingBalances[msg.sender]));
            }
            holdingBalances[msg.sender] = 0;
        }
        else {
            assert(token.transfer(msg.sender, amount));
            holdingBalances[msg.sender] = holdingBalances[msg.sender].sub(amount);
        }
        return true;
    }

    /*
     * @dev increase balance has in this contract
     * @param receiver receiver of tokens
     * @param amount amount of money
     */
    function increaseBalance(address receiver, uint amount) public onlyOwner {
        require(block.timestamp < endTime);

        assert(tokenDistributed.add(amount) > totalToken);

        holdingBalances[receiver] = holdingBalances[receiver].add(amount);
        tokenDistributed = tokenDistributed.add(amount);
    }
}

contract PlusPlusCrowdsale is Crowdsale {
    // contract holding tokens of owner
    TokenVault public vault;

    function PlusPlusCrowdsale () public 
    Crowdsale()
    {
        vault = new TokenVault(token);
        token.transfer(vault, 2000000000000000000000000); 
    }

    function buyTriracleToken(address sender) public payable {
        buyTokens(sender);
    }

    function () public payable {
        buyTriracleToken(msg.sender);
    }

    function distributeVault(address receiver, uint amount) public onlyOwner {
        vault.increaseBalance(receiver, amount);
    }
}
