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

    /**
     * @dev Contructor of token
     */
    function TriracleToken(uint _startTime, uint _endTime) public {
        name = "TPP ICO TOKEN SALE";
        symbol = "TPP";
        decimals = 18;
        startTime = _startTime;
        endTime = _endTime;
    }

    /**
     * @dev overwrite transfer
     */
    function transfer(address to, uint value) public returns (bool) {
        require(to != address(0x0));
        require(block.timestamp >= endTime);

        super.transfer(to, value);
    }

    /**
     * @dev overwrite transferFrom
     */
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(to != address(0x0));
        require(block.timestamp >= endTime);

        super.transferFrom(from, to, value);
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
    // amount of bonus
    // bonus (can be set anytime in crowdsale)
    uint public bonus;
    // maximum amount can buy
    uint public balanceLimit;
    
    /**
     * @dev contructor for crowdsale
     */
    function Crowdsale() public {
        token = createToken();
        wallet = msg.sender;
        balanceLimit = 1000000000000000000000000;
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
     */
    function forwardFund() internal {
        if (this.balance > 0) {
            wallet.transfer(this.balance);
        }
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

    // 02/03/2018 12AM
    uint startTime = 1519974000;
    uint stage1 = startTime + 4 hours;
    uint endTime = stage1 + 2 hours;

    /**
     * @dev Fallback function to buy token
     */
    function () public payable {
        buyTokens(msg.sender);
    }

    /**
     * check if exceed balance limit then refund to buyer the exceeded
     * @dev Forward fund to address
     * @param benificary Who buy token
     */
    function buyTokens(address benificary) payable public {
        require(benificary != address(0x0));
        require(msg.value != 0);
        require(!hasEnd());

        uint weiAmount = msg.value;
        uint tokenAmount;

        if (bonus != 0) {
            uint bonusAmount = weiAmount.mul(bonus).div(100);
            if (block.timestamp >= startTime && block.timestamp < stage1) {
                tokenAmount = weiAmount.mul(1200); // 20% bonus in stage1
                tokenAmount.add(bonusAmount);
            }
            else {
                tokenAmount = weiAmount.mul(1000);
                tokenAmount.add(bonusAmount);
            }
        }
        else {
            if (block.timestamp >= startTime && block.timestamp < stage1) {
                tokenAmount = weiAmount.mul(1200); // 20% bonus in stage1
            }
            else {
                tokenAmount = weiAmount.mul(1000);
            }
        }

        uint totalBalance = tokenAmount + token.balanceOf(benificary);
        if (totalBalance <= balanceLimit) {
            forwardFund();
            totalWeiRaised = totalWeiRaised.add(weiAmount);
            token.mint(benificary, tokenAmount);
        }
        else {
            uint refund = totalBalance - balanceLimit;
            uint refundWeiAmount;
            if (bonus != 0) {
                if (block.timestamp >= startTime && block.timestamp < stage1) {
                    // tokenAmount = weiAmount * (20 + bonus) * 10
                    refundWeiAmount = refund.div(10).div(20 + bonus);
                }
                else {
                    refundWeiAmount = refund.div(10).div(bonus);
                }
            }
            else {
                if (block.timestamp >= startTime && block.timestamp < stage1) {
                    refundWeiAmount = refund.div(1200); // 20% bonus in stage1
                }
                else {
                    refundWeiAmount = refund.div(1000);
                }
            }
            refundExceed(benificary, weiAmount);
            forwardFund();
            weiAmount = weiAmount.sub(refundWeiAmount);
            tokenAmount = tokenAmount.sub(refund);
            if (tokenAmount != 0) {
                token.mint(benificary, tokenAmount);
                totalWeiRaised = totalWeiRaised.add(weiAmount);
            }
        }
    }

    /**
     * @dev Destroy some token
     * @param amount Amount of destroyed token
     */
    function destroyToken(uint amount) public onlyOwner {
        token.destroy(amount.mul(1000000000000000000), msg.sender);
    }

    /**
     * @dev Mint some tokens for an address (may be they paid by others coin)
     * @param benificary receiver address
     * @param tokenAmount total tokens were received
     */
    function mintToken(address benificary, uint tokenAmount) internal {
        require(benificary != address(0x0));

        uint weiAmount;
        if (bonus != 0) {
            if (block.timestamp >= startTime && block.timestamp < stage1) {
                // tokenAmount = weiAmount * (20 + bonus) * 10
                weiAmount = tokenAmount.div(10).div(20 + bonus);
            }
            else {
                weiAmount = tokenAmount.div(10).div(bonus);
            }
        }
        else {
            if (block.timestamp >= startTime && block.timestamp < stage1) {
                weiAmount = tokenAmount.div(1200); // 20% bonus in stage1
            }
            else {
                weiAmount = tokenAmount.div(1000);
            }
        }

        totalWeiRaised = totalWeiRaised.add(weiAmount);
        token.mint(benificary, tokenAmount);
    }

    /**
     * @dev Set bonus for crowdsale
     * @param _bonus bonus (%)
     */
    function setBonus(uint _bonus) public onlyOwner {
        bonus = _bonus;
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
}

contract PlusPlusCrowdsale is Crowdsale {
    function PlusPlusCrowdsale () public 
    Crowdsale()
    {

    }

    function mintTriracleToken(address benificary, uint amount) public onlyOwner {
        mintToken(benificary, amount);
    }

    function buyTriracleToken(address sender) public payable {
        buyTokens(sender);
    }

    function () public payable {
        buyTriracleToken(msg.sender);
    }
}
