// SPDX-License-Identifier: MIT

pragma solidity >=0.8.24 <0.9.0;

/**
 * @title Context
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, as when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 * @notice This contract is used through inheritance. It will make available the
 * modifier `_msgSender()`, which can be used to reference the account that
 * called a function within an implementing contract.
 */
abstract contract Context {
    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets the sender of the current call
     * @dev Provides a way to retrieve the message sender that supports meta-transactions
     * @return Sender address (msg.sender in the base implementation)
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @notice Gets the complete calldata of the current call
     * @dev Provides a way to retrieve the message data that supports meta-transactions
     * @return Complete calldata bytes
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @notice Gets the length of any context-specific suffix in the message data
     * @dev Used in meta-transaction implementations to account for additional data
     * @return Length of the context suffix (0 in the base implementation)
     */
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title Ownable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 * @notice By default, the owner account will be the one that deploys the contract.
 * This can later be changed with {transferOwnership} and {renounceOwnership}.
 */
abstract contract Ownable is Context {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Address of the current owner
    address private _owner;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when ownership is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Thrown when non-owner tries to call owner-only function
    error UnauthorizedAccount(address account);
    /// @notice Thrown when trying to transfer ownership to invalid address
    error InvalidOwner(address owner);
    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Throws if called by any account other than the owner
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Initializes the contract setting the deployer as the initial owner
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Leaves the contract without owner
     * @dev Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @notice Transfers ownership of the contract to a new account
     * @dev The new owner cannot be the zero address
     * @param newOwner The address that will become the new owner
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert InvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns the address of the current owner
     * @return Current owner address
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`)
     * Internal function without access restriction
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Throws if the sender is not the owner
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert UnauthorizedAccount(_msgSender());
        }
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title InUSDProvider
 * @dev Interface for nUSD token provision and distribution operations
 * @notice Defines functionality for:
 * 1. Token provision management
 * 2. Supply control
 * 3. Distribution tracking
 */
interface InUSDProvider {
    /*//////////////////////////////////////////////////////////////
                        PROVISION OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Provides nUSD tokens to the requesting address
     * @param amount The quantity of nUSD tokens to provide in base units
     * @dev Handles:
     * · Token minting/transfer
     * · Supply tracking
     * · State updates
     *
     * Requirements:
     * · Caller is authorized
     * · Amount > 0
     * · Within supply limits
     *
     * Effects:
     * · Increases recipient balance
     * · Updates total supply
     * · Emits provision event
     */
    function provide(uint256 amount) external;
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IDynamicInterestRate
 * @dev Interface for dynamic interest rate calculations in the lending protocol
 * @notice Defines methods for retrieving time-based interest rates that:
 * 1. Adjust based on market conditions
 * 2. Support per-second and base rate calculations
 * 3. Maintain precision through proper scaling
 *
 * This interface is crucial for:
 * · Accurate interest accrual
 * · Dynamic market response
 * · Protocol yield calculations
 */
interface IDynamicInterestRate {
    /*//////////////////////////////////////////////////////////////
                        INTEREST RATE QUERIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves the current interest rate per second
     * @return uint256 Interest rate per second, scaled by 1e18
     * @dev Used for precise interest calculations over time periods
     */
    function getInterestPerSecond() external view returns (uint256);

    /**
     * @notice Retrieves the current base interest rate
     * @return uint256 Base interest rate, scaled by 1e18
     * @dev Represents the foundational rate before adjustments
     */
    function getInterestRate() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20Custom
 * @dev Interface for the ERC20 fungible token standard (EIP-20)
 * @notice Defines functionality for:
 * 1. Token transfers
 * 2. Allowance management
 * 3. Balance tracking
 * 4. Token metadata
 */
interface IERC20Custom {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Emitted on token transfer between addresses
     * @param from Source address (0x0 for mints)
     * @param to Destination address (0x0 for burns)
     * @param value Amount of tokens transferred
     * @notice Tracks:
     * · Regular transfers
     * · Minting operations
     * · Burning operations
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @dev Emitted when spending allowance is granted
     * @param owner Address granting permission
     * @param spender Address receiving permission
     * @param value Amount of tokens approved
     * @notice Records:
     * · New approvals
     * · Updated allowances
     * · Revoked permissions
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /*//////////////////////////////////////////////////////////////
                        TRANSFER OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Transfers tokens to specified recipient
     * @param to Recipient address
     * @param value Amount to transfer in base units
     * @return bool True if transfer succeeds
     * @dev Requirements:
     * · Caller has sufficient balance
     * · Recipient is valid
     * · Amount > 0
     *
     * Effects:
     * · Decreases caller balance
     * · Increases recipient balance
     * · Emits Transfer event
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @notice Executes transfer on behalf of token owner
     * @param from Source address
     * @param to Destination address
     * @param value Amount to transfer in base units
     * @return bool True if transfer succeeds
     * @dev Requirements:
     * · Caller has sufficient allowance
     * · Source has sufficient balance
     * · Valid addresses
     *
     * Effects:
     * · Decreases allowance
     * · Updates balances
     * · Emits Transfer event
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    /*//////////////////////////////////////////////////////////////
                        APPROVAL OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Authorizes address to spend tokens
     * @param spender Address to authorize
     * @param value Amount to authorize in base units
     * @return bool True if approval succeeds
     * @dev Controls:
     * · Spending permissions
     * · Delegation limits
     * · Authorization levels
     *
     * Security:
     * · Overwrites previous allowance
     * · Requires explicit value
     * · Emits Approval event
     */
    function approve(address spender, uint256 value) external returns (bool);

    /*//////////////////////////////////////////////////////////////
                            TOKEN METADATA
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves human-readable token name
     * @return string Full token name
     */
    function name() external view returns (string memory);

    /**
     * @notice Retrieves token trading symbol
     * @return string Short token identifier
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Retrieves token decimal precision
     * @return uint8 Number of decimal places
     * @dev Standard:
     * · 18 for most tokens
     * · Used for display formatting
     */
    function decimals() external view returns (uint8);

    /*//////////////////////////////////////////////////////////////
                            BALANCE QUERIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves total token supply
     * @return uint256 Current total supply
     * @dev Reflects:
     * · All minted tokens
     * · Minus burned tokens
     * · In base units
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Retrieves account token balance
     * @param account Address to query
     * @return uint256 Current balance in base units
     * @dev Returns:
     * · Available balance
     * · Includes pending rewards
     * · Excludes locked tokens
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Retrieves remaining spending allowance
     * @param owner Token owner address
     * @param spender Authorized spender address
     * @return uint256 Current allowance in base units
     * @dev Shows:
     * · Approved amount
     * · Remaining limit
     * · Delegation status
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20Errors
 * @dev Standardized error interface for ERC20 token operations
 * @notice Defines functionality for:
 * 1. Balance validation errors
 * 2. Address validation errors
 * 3. Allowance validation errors
 */
interface IERC20Errors {
    /*//////////////////////////////////////////////////////////////
                        BALANCE ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for insufficient token balance
     * @param sender Address attempting the transfer
     * @param balance Current balance of sender
     * @param needed Amount attempting to transfer
     * @notice Triggered when:
     * · Transfer amount > balance
     * · Burn amount > balance
     * · Withdrawal > available
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );
    /*//////////////////////////////////////////////////////////////
                        ADDRESS VALIDATION ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for invalid sending address
     * @param sender Address that failed validation
     * @notice Triggered when:
     * · Sender is zero address
     * · Sender is blacklisted
     * · Sender lacks permissions
     */
    error ERC20InvalidSender(address sender);
    /**
     * @dev Error for invalid receiving address
     * @param receiver Address that failed validation
     * @notice Triggered when:
     * · Receiver is zero address
     * · Receiver is blacklisted
     * · Receiver is contract without implementation
     */
    error ERC20InvalidReceiver(address receiver);
    /*//////////////////////////////////////////////////////////////
                        ALLOWANCE ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for insufficient spending allowance
     * @param spender Address attempting to spend
     * @param allowance Current approved amount
     * @param needed Amount attempting to spend
     * @notice Triggered when:
     * · Spend amount > allowance
     * · Transfer amount > approved
     * · Delegation exceeds limits
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );
    /**
     * @dev Error for invalid approving address
     * @param approver Address that failed validation
     * @notice Triggered when:
     * · Approver is zero address
     * · Approver lacks permissions
     * · Approver is invalid state
     */
    error ERC20InvalidApprover(address approver);
    /**
     * @dev Error for invalid spending address
     * @param spender Address that failed validation
     * @notice Triggered when:
     * · Spender is zero address
     * · Spender is blacklisted
     * · Spender lacks permissions
     */
    error ERC20InvalidSpender(address spender);
}
pragma solidity >=0.8.24 <0.9.0;
/**
 * @title IERC20Token
 * @dev Extended interface for ERC20 tokens with supply control capabilities
 * @notice Defines functionality for:
 * 1. Token minting
 * 2. Token burning
 * 3. Supply management
 */
interface IERC20Token is IERC20Custom {
    /*//////////////////////////////////////////////////////////////
                        SUPPLY MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Mints new tokens to specified account
     * @param account Address to receive minted tokens
     * @param amount Quantity of tokens to mint in base units
     * @dev Controls:
     * · Supply expansion
     * · Balance updates
     * · Event emission
     *
     * Requirements:
     * · Caller is authorized
     * · Within maxSupply
     * · Valid recipient
     */
    function mint(address account, uint256 amount) external;

    /**
     * @notice Burns tokens from specified account
     * @param account Address to burn tokens from
     * @param amount Quantity of tokens to burn in base units
     * @dev Manages:
     * · Supply reduction
     * · Balance updates
     * · Event emission
     *
     * Requirements:
     * · Caller is authorized
     * · Sufficient balance
     * · Amount > 0
     */
    function burn(address account, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves maximum token supply limit
     * @return uint256 Maximum supply cap in base units
     * @dev Enforces:
     * · Supply ceiling
     * · Mint restrictions
     * · Protocol limits
     *
     * Note: This is an immutable value that
     * cannot be exceeded by minting operations
     */
    function maxSupply() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20TokenRebase
 * @dev Extended interface for ERC20 tokens with elastic supply and safe management
 * @notice Defines functionality for:
 * 1. Supply elasticity (rebasing)
 * 2. Safe-based token management
 * 3. Supply control mechanisms
 * 4. Configuration management
 */
interface IERC20TokenRebase is IERC20Custom {
    /*//////////////////////////////////////////////////////////////
                        SUPPLY MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Mints new tokens to specified account
     * @param account Address to receive minted tokens
     * @param amount Quantity of tokens to mint in base units
     * @dev Requires:
     * · Caller is authorized minter
     * · Within maxSupply limits
     * · Valid recipient
     */
    function mint(address account, uint256 amount) external;

    /**
     * @notice Burns tokens from specified account
     * @param account Address to burn tokens from
     * @param amount Quantity of tokens to burn in base units
     * @dev Requires:
     * · Caller is authorized
     * · Account has sufficient balance
     * · Amount > 0
     */
    function burn(address account, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                        REBASE OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Executes supply rebase based on current parameters
     * @dev Triggers:
     * · Supply adjustment
     * · Balance recalculation
     * · Event emission
     *
     * Considers:
     * · Rebase interval
     * · Basis points
     * · Supply limits
     */
    function rebase() external;

    /**
     * @notice Configures rebase parameters
     * @param rebaseInterval Time period between rebases (in seconds)
     * @param rebaseBasisPoints Scale factor for rebase (in basis points)
     * @dev Controls:
     * · Rebase frequency
     * · Rebase magnitude
     * · Supply elasticity
     */
    function setRebaseConfig(
        uint256 rebaseInterval,
        uint256 rebaseBasisPoints
    ) external;

    /*//////////////////////////////////////////////////////////////
                        SAFE MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes new token management safe
     * @param safe Address of safe to create
     * @dev Establishes:
     * · Safe permissions
     * · Access controls
     * · Management capabilities
     */
    function createSafe(address safe) external;

    /**
     * @notice Removes existing token management safe
     * @param safe Address of safe to remove
     * @dev Handles:
     * · Permission revocation
     * · State cleanup
     * · Access termination
     */
    function destroySafe(address safe) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves floor contract address
     * @return address Active floor contract
     * @dev Used for:
     * · Price stability
     * · Supply control
     */
    function floor() external view returns (address);

    /**
     * @notice Retrieves authorized minter address
     * @return address Active minter contract
     * @dev Controls:
     * · Mint permissions
     * · Supply expansion
     */
    function minter() external view returns (address);

    /**
     * @notice Returns absolute maximum token supply
     * @return uint256 Maximum supply cap in base units
     * @dev Enforces:
     * · Hard supply limit
     * · Mint restrictions
     */
    function maxSupply() external view returns (uint256);

    /**
     * @notice Calculates maximum supply after rebase
     * @return uint256 Post-rebase maximum supply in base units
     * @dev Considers:
     * · Current max supply
     * · Rebase parameters
     * · Supply caps
     */
    function maxSupplyRebased() external view returns (uint256);

    /**
     * @notice Calculates total supply after rebase
     * @return uint256 Post-rebase total supply in base units
     * @dev Reflects:
     * · Current supply
     * · Rebase effects
     * · Supply limits
     */
    function totalSupplyRebased() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IFeesWithdrawer
 * @dev Interface for protocol fee withdrawal operations
 * @notice Defines functionality for:
 * 1. Secure fee withdrawal
 * 2. Access control for withdrawals
 * 3. Protocol revenue management
 *
 * This interface ensures:
 * · Controlled access to protocol fees
 * · Safe transfer of accumulated revenue
 * · Proper accounting of withdrawn amounts
 */
interface IFeesWithdrawer {
    /*//////////////////////////////////////////////////////////////
                        WITHDRAWAL OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Withdraws accumulated protocol fees to designated recipients
     * @dev Only callable by authorized withdrawers
     * Handles:
     * · Fee accounting updates
     * · Transfer of tokens
     * · Event emission for tracking
     */
    function withdraw() external;
}

/**
 * @title IFeesDistributor
 * @dev Interface for protocol fee distribution and allocation
 * @notice Defines functionality for:
 * 1. Fee distribution across protocol components
 * 2. Dynamic allocation management
 * 3. Floor token revenue sharing
 *
 * This interface manages:
 * · Revenue distribution logic
 * · Allocation percentages
 * · Protocol incentive mechanisms
 */
interface IFeesDistributor {
    /*//////////////////////////////////////////////////////////////
                        DISTRIBUTION OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Distributes accumulated protocol fees according to set allocations
     * @dev Handles the distribution of fees to:
     * · Floor token stakers
     * · Protocol treasury
     * · Other designated recipients
     */
    function distribute() external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns current percentage allocated to Floor token stakers
     * @return uint256 Floor allocation percentage, scaled by 1e18
     */
    function floorAllocation() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IFloor
 * @dev Interface for protocol floor price management and capital operations
 * @notice Defines functionality for:
 * 1. Token deposit management
 * 2. Refund processing
 * 3. Capital tracking
 */
interface IFloor {
    /*//////////////////////////////////////////////////////////////
                        DEPOSIT OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes token deposits into the floor contract
     * @param msgSender Address initiating the deposit
     * @param amount Quantity of tokens to deposit
     * @dev Handles:
     * · Token transfer validation
     * · Capital tracking updates
     * · Event emission
     */
    function deposit(address msgSender, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                        REFUND OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes token refunds from the floor contract
     * @param msgSender Address receiving the refund
     * @param amount Quantity of tokens to refund
     * @dev Ensures:
     * · Sufficient contract balance
     * · Authorized withdrawal
     * · Capital accounting
     */
    function refund(address msgSender, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns current total capital held in the floor contract
     * @return uint256 Current capital amount in base units
     * @dev Used for:
     * · Floor price calculations
     * · Protocol health metrics
     * · Capital adequacy checks
     */
    function capital() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IMinter
 * @dev Interface for the Minter contract
 */
interface IMinter {
    /**
     * @notice Enables whitelist minting phase
     */
    function enableWhitelistMint() external;

    /**
     * @notice Enables public minting phase
     */
    function enablePublicMint() external;

    /**
     * @notice Adds a wallet to the whitelist
     * @param wallet Wallet address to whitelist
     */
    function addToWhitelist(address wallet) external;

    /**
     * @notice Mints tokens during whitelist phase
     * @param stablecoin Stablecoin used for minting
     * @param stableAmount Amount of stablecoin to mint against
     */
    function whitelistMint(
        IERC20Custom stablecoin,
        uint256 stableAmount
    ) external;

    /**
     * @notice Mints tokens during public phase
     * @param stablecoin Stablecoin used for minting
     * @param stableAmount Amount of stablecoin to mint against
     */
    function publicMint(IERC20Custom stablecoin, uint256 stableAmount) external;

    /**
     * @notice Mints remaining token supply
     * @param stablecoin Stablecoin used for minting
     */
    function mintRemainingSupply(IERC20Custom stablecoin) external;

    /**
     * @notice Sends accumulated nUSD to floor contract
     */
    function sendToFloornUSD() external;

    /**
     * @notice Verifies if a wallet is whitelisted
     * @param wallet Address to verify
     * @return bool Whitelist status
     */
    function verifyWallet(address wallet) external view returns (bool);

    /**
     * @notice Calculates mint amount for given stablecoin input
     * @param stablecoin Stablecoin used for calculation
     * @param stableAmount Amount of stablecoin
     * @return uint256 Calculated mint amount
     */
    function calcMintAmount(
        IERC20Custom stablecoin,
        uint256 stableAmount
    ) external view returns (uint256);

    /**
     * @notice Gets the current token reserve
     * @return uint256 Current token reserve
     */
    function tokenReserve() external view returns (uint256);

    /**
     * @notice Gets the current mint ratio
     * @return uint256 Current mint ratio
     */
    function getCurrentRatio() external view returns (uint256);

    /**
     * @notice Gets the current mint rate
     * @return uint256 Current mint rate
     */
    function getCurrentRate() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IOracle
 * @dev Interface for basic price feed operations
 * @notice Defines functionality for:
 * 1. Asset price retrieval
 * 2. Price precision handling
 */
interface IOracle {
    /*//////////////////////////////////////////////////////////////
                            PRICE QUERIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves current asset price
     * @param asset Address of the asset to price
     * @return uint256 Current price in base units with precision
     * @dev Provides:
     * · Latest price data
     * · Standardized precision
     * · Asset valuation
     *
     * Note: Check implementation for specific precision details
     */
    function getPrice(address asset) external view returns (uint256);
}

/**
 * @title ITwapOracle
 * @dev Interface for time-weighted average price calculations
 * @notice Defines functionality for:
 * 1. TWAP updates
 * 2. Time-weighted calculations
 * 3. Price smoothing
 */
interface ITwapOracle {
    /*//////////////////////////////////////////////////////////////
                            TWAP OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Updates time-weighted average price
     * @param asset Address of the asset to update
     * @return uint256 New TWAP value in base units
     * @dev Calculates:
     * · Time-weighted price
     * · Cumulative values
     * · Price averages
     *
     * Features:
     * · Manipulation resistance
     * · Smoothing effect
     * · Historical tracking
     */
    function updateTwap(address asset) external returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IPSM
 * @dev Interface for Peg Stability Module (PSM) operations
 * @notice Defines functionality for:
 * 1. Stablecoin/nUSD swaps
 * 2. Peg maintenance
 * 3. Supply tracking
 */
interface IPSM {
    /*//////////////////////////////////////////////////////////////
                            SWAP OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Executes stablecoin to nUSD swap
     * @param msgSender Address initiating the swap
     * @param receiver Address receiving the nUSD
     * @param stableTokenAmount Amount of stablecoins to swap
     * @dev Handles:
     * · Stablecoin deposit
     * · nUSD minting
     * · Supply tracking
     */
    function swapStableFornUSD(
        address msgSender,
        address receiver,
        uint256 stableTokenAmount
    ) external;

    /**
     * @notice Executes nUSD to stablecoin swap
     * @param msgSender Address initiating the swap
     * @param receiver Address receiving the stablecoins
     * @param stableTokenAmount Amount of stablecoins to receive
     * @dev Handles:
     * · nUSD burning
     * · Stablecoin release
     * · Supply adjustment
     */
    function swapnUSDForStable(
        address msgSender,
        address receiver,
        uint256 stableTokenAmount
    ) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves the stablecoin token contract
     * @return IERC20Custom Stablecoin token interface
     * @dev Used for:
     * · Token transfers
     * · Balance checks
     * · Allowance verification
     */
    function stableToken() external view returns (IERC20Custom);

    /**
     * @notice Returns total nUSD tokens minted through PSM
     * @return uint256 Total minted amount in base units
     * @dev Tracks:
     * · Total supply impact
     * · PSM utilization
     * · Protocol growth metrics
     */
    function nusdMinted() external view returns (uint256);

    /**
     * @notice Returns the maximum amount of nUSD that can be minted through PSM
     * @return uint256 Maximum mintable amount in base units
     * @dev Used for:
     * · Supply control
     * · Risk management
     * · Protocol safety
     */
    function nusdMintCap() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IStableOwner Interface
 * @dev Interface for StableOwner contract that manages stable token supply
 * @notice Defines the external interface for stable token supply management
 */
interface IStableOwner {
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when stable token contract is updated
    /// @param stable New stable token contract address
    event StableSet(IERC20Token indexed stable);
    /// @notice Emitted when new tokens are minted
    /// @param account Recipient of minted tokens
    /// @param amount Amount of tokens minted
    event TokensMinted(address indexed account, uint256 amount);
    /// @notice Emitted when tokens are burned
    /// @param account Account tokens were burned from
    /// @param amount Amount of tokens burned
    event TokensBurned(address indexed account, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Updates the stable token contract address
    /// @param stable_ New stable token contract address
    function setStable(IERC20Token stable_) external;

    /// @notice Creates new stable tokens
    /// @param account Address to receive minted tokens
    /// @param amount Number of tokens to mint
    function mint(address account, uint256 amount) external;

    /// @notice Destroys existing stable tokens
    /// @param account Address to burn tokens from
    /// @param amount Number of tokens to burn
    function burn(address account, uint256 amount) external;

    /// @notice The managed stable token contract
    /// @return The IERC20Token interface of the stable token
    function stable() external view returns (IERC20Token);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IStakednUSD
 * @dev Interface for staked nUSD token operations and reward distribution
 * @notice Defines functionality for:
 * 1. nUSD token staking
 * 2. Reward distribution
 * 3. Position management
 */
interface IStakednUSD {
    /*//////////////////////////////////////////////////////////////
                        REWARD DISTRIBUTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Distributes protocol fees as staking rewards
     * @param amount Amount of fees to distribute in base units
     * @dev Handles:
     * · Pro-rata distribution
     * · Reward accounting
     * · Distribution events
     *
     * Rewards are:
     * · Automatically calculated
     * · Immediately available
     * · Proportional to stake
     */
    function distributeFees(uint256 amount) external;

    /**
     * @notice Claims pending fee rewards for the caller
     * @return claimedAmount Amount of fees claimed
     * @dev Allows users to manually claim their accumulated fees
     */
    function claimFees() external returns (uint256 claimedAmount);

    /*//////////////////////////////////////////////////////////////
                        STAKING OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes nUSD token deposits for staking
     * @param from Address providing the tokens
     * @param to Address receiving the staked position
     * @param amount Quantity of tokens to stake in base units
     * @dev Manages:
     * · Token transfers
     * · Position creation
     * · Reward calculations
     *
     * Supports:
     * · Direct deposits
     * · Delegated deposits
     * · Position tracking
     */
    function deposit(address from, address to, uint256 amount) external;

    /**
     * @notice Initiates a withdrawal from staked nUSD
     * @param amount Amount of tokens to withdraw
     */
    function beginWithdrawal(uint256 amount) external;

    /**
     * @notice Processes withdrawal of staked nUSD tokens
     * @param account Address withdrawing tokens
     * @dev Handles:
     * · Position updates
     * · Reward claims
     * · Token transfers
     *
     * Ensures:
     * · Sufficient balance
     * · Reward distribution
     * · Clean exit
     */
    function withdraw(address account) external;

    /**
     * @notice Views pending unclaimed fees for an account
     * @param account Address to check for pending fees
     * @return pendingAmount Amount of pending fees available to claim
     * @dev Calculates based on the fee accumulator and account's last claimed value
     */
    function pendingFees(
        address account
    ) external view returns (uint256 pendingAmount);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title ISupplyHangingCalculator
 * @dev Interface for calculating and managing token supply adjustments
 * @notice Defines functionality for:
 * 1. Supply hanging calculations
 * 2. Safety margin management
 * 3. Risk-adjusted metrics
 */
interface ISupplyHangingCalculator {
    /*//////////////////////////////////////////////////////////////
                        SAFETY PARAMETERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves current safety margin for supply calculations
     * @return uint256 Safety margin percentage scaled by 1e18
     * @dev Used for:
     * · Risk adjustment
     * · Supply buffer
     * · Protocol protection
     */
    function safetyMargin() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                    SUPPLY HANGING CALCULATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Calculates current supply hanging with safety margins
     * @return uint256 Risk-adjusted supply hanging in base units
     * @dev Includes:
     * · Safety margin application
     * · Risk adjustments
     * · Protocol constraints
     *
     * Used for:
     * · Safe supply management
     * · Conservative adjustments
     * · Risk-aware operations
     */
    function getSupplyHanging() external view returns (uint256);

    /**
     * @notice Calculates raw supply hanging without safety margins
     * @return uint256 Unadjusted supply hanging in base units
     * @dev Provides:
     * · Raw calculations
     * · No safety buffers
     * · Maximum theoretical values
     *
     * Used for:
     * · Analysis purposes
     * · Maximum bounds
     * · Stress testing
     */
    function getSupplyHangingUnsafe() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IVoteEscrowedNIV
 * @dev Interface for vote-escrowed NIV (veNIV) token operations
 * @notice Defines functionality for:
 * 1. Token withdrawal management
 * 2. Escrow position handling
 * 3. Voting power release
 */
interface IVoteEscrowedNIV {
    /*//////////////////////////////////////////////////////////////
                        WITHDRAWAL OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes withdrawal of escrowed NIV tokens
     * @dev Handles:
     * · Lock period verification
     * · Position liquidation
     * · Token transfers
     *
     * Requirements:
     * · Lock period expired
     * · Active position exists
     * · Caller is position owner
     *
     * Effects:
     * · Releases locked tokens
     * · Removes voting power
     * · Clears escrow position
     */
    function withdraw() external;
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title Rebase Library
 * @dev Library for handling elastic supply token calculations and adjustments
 * @notice This library provides mathematical operations for elastic/base token conversions
 * and supply adjustments. It handles two key concepts:
 *
 * 1. Elastic Supply: The actual total supply that can expand or contract
 * 2. Base Supply: The underlying base amount that remains constant
 */
/*//////////////////////////////////////////////////////////////
                               TYPES
//////////////////////////////////////////////////////////////*/
/**
 * @dev Core data structure for elastic supply tracking
 * @param elastic Current elastic (rebased) supply
 * @param base Current base (non-rebased) supply
 */
struct Rebase {
    uint256 elastic;
    uint256 base;
}

/**
 * @title AuxRebase
 * @dev Auxiliary functions for elastic supply calculations
 * @notice Provides safe mathematical operations for elastic/base conversions
 * with optional rounding control
 */
library AuxRebase {
    /*//////////////////////////////////////////////////////////////
                         ELASTIC SUPPLY OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Increases the elastic supply
     * @param total Current total supply state
     * @param elastic Amount to add to elastic supply
     * @return newElastic Updated elastic supply after addition
     */
    function addElastic(
        Rebase storage total,
        uint256 elastic
    ) internal returns (uint256 newElastic) {
        newElastic = total.elastic += elastic;
    }

    /**
     * @notice Decreases the elastic supply
     * @param total Current total supply state
     * @param elastic Amount to subtract from elastic supply
     * @return newElastic Updated elastic supply after subtraction
     */
    function subElastic(
        Rebase storage total,
        uint256 elastic
    ) internal returns (uint256 newElastic) {
        newElastic = total.elastic -= elastic;
    }

    /*//////////////////////////////////////////////////////////////
                         CONVERSION OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Converts an elastic amount to its base amount
     * @param total Current total supply state
     * @param elastic Amount of elastic tokens to convert
     * @param roundUp If true, rounds up the result
     * @return base Equivalent amount in base units
     * @dev
     * · If elastic supply is 0, returns elastic amount as base
     * · Handles potential precision loss during conversion
     * · Rounding can cause slight variations in converted amounts
     * · Recommended for scenarios requiring precise supply tracking
     *
     * Rounding Behavior:
     * · roundUp = false: Always rounds down (truncates)
     * · roundUp = true: Rounds up if there's a fractional remainder
     *
     * Edge Cases:
     * · total.elastic == 0: Returns input elastic as base
     * · Potential for minimal precision differences
     */
    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = (elastic * total.base) / total.elastic;
            if (roundUp && (base * total.elastic) / total.base < elastic) {
                base++;
            }
        }
    }

    /**
     * @notice Converts a base amount to its elastic amount
     * @param total Current total supply state
     * @param base Amount of base tokens to convert
     * @param roundUp If true, rounds up the result
     * @return elastic Equivalent amount in elastic units
     * @dev
     * · If base supply is 0, returns base amount as elastic
     * · Handles potential precision loss during conversion
     * · Rounding can cause slight variations in converted amounts
     * · Recommended for scenarios requiring precise supply tracking
     *
     * Rounding Behavior:
     * · roundUp = false: Always rounds down (truncates)
     * · roundUp = true: Rounds up if there's a fractional remainder
     *
     * Edge Cases:
     * · total.base == 0: Returns input base as elastic
     * · Potential for minimal precision differences
     */
    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = (base * total.elastic) / total.base;
            if (roundUp && (elastic * total.base) / total.elastic < base) {
                elastic++;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                         COMBINED OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Adds elastic tokens and calculates corresponding base amount
     * @param total Current total supply state
     * @param elastic Amount of elastic tokens to add
     * @param roundUp If true, rounds up base conversion
     * @return (Rebase, uint256) Updated total supply and calculated base amount
     */
    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic += elastic;
        total.base += base;
        return (total, base);
    }

    /**
     * @notice Subtracts base tokens and calculates corresponding elastic amount
     * @param total Current total supply state
     * @param base Amount of base tokens to subtract
     * @param roundUp If true, rounds up elastic conversion
     * @return (Rebase, uint256) Updated total supply and calculated elastic amount
     */
    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic -= elastic;
        total.base -= base;
        return (total, elastic);
    }

    /**
     * @notice Adds specific amounts to both elastic and base supplies
     * @param total Current total supply state
     * @param elastic Amount of elastic tokens to add
     * @param base Amount of base tokens to add
     * @return Rebase Updated total supply after addition
     */
    function add(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic += elastic;
        total.base += base;
        return total;
    }

    /**
     * @notice Subtracts specific amounts from both elastic and base supplies
     * @param total Current total supply state
     * @param elastic Amount of elastic tokens to subtract
     * @param base Amount of base tokens to subtract
     * @return Rebase Updated total supply after subtraction
     */
    function sub(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic -= elastic;
        total.base -= base;
        return total;
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IVault
 * @dev Interface for advanced vault operations with elastic share system
 * @notice Defines functionality for:
 * 1. Token custody and management
 * 2. Share-based accounting
 * 3. Elastic supply mechanics
 * 4. Amount/share conversions
 */
interface IVault {
    /*//////////////////////////////////////////////////////////////
                        DEPOSIT OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes token deposits into vault
     * @param token Token contract to deposit
     * @param from Source of tokens
     * @param to Recipient of shares
     * @param amount Token amount (in base units, 0 for share-based)
     * @param share Share amount (0 for amount-based)
     * @return amountIn Actual tokens deposited
     * @return shareIn Actual shares minted
     * @dev Handles:
     * · Token transfers
     * · Share minting
     * · Balance updates
     *
     * Requirements:
     * · Valid token contract
     * · Authorized caller
     * · Sufficient balance
     * · Either amount or share > 0
     *
     * Note: Only one of amount/share should be non-zero
     */
    function deposit(
        IERC20Custom token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountIn, uint256 shareIn);

    /*//////////////////////////////////////////////////////////////
                        WITHDRAWAL OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes token withdrawals from vault
     * @param token Token contract to withdraw
     * @param from Source of shares
     * @param to Recipient of tokens
     * @param amount Token amount (in base units, 0 for share-based)
     * @param share Share amount (0 for amount-based)
     * @return amountOut Actual tokens withdrawn
     * @return shareOut Actual shares burned
     * @dev Manages:
     * · Share burning
     * · Token transfers
     * · Balance updates
     *
     * Requirements:
     * · Valid token contract
     * · Sufficient shares
     * · Either amount or share > 0
     * · Authorized withdrawal
     *
     * Security:
     * · Validates balances
     * · Checks permissions
     * · Updates state atomically
     */
    function withdraw(
        IERC20Custom token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

    /*//////////////////////////////////////////////////////////////
                        SHARE TRANSFERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Transfers vault shares between accounts
     * @param token Associated token contract
     * @param from Source of shares
     * @param to Recipient of shares
     * @param share Amount of shares to transfer
     * @dev Executes:
     * · Direct share movement
     * · Balance updates
     * · Event emission
     *
     * Requirements:
     * · Sufficient share balance
     * · Valid addresses
     * · Share amount > 0
     *
     * Note: Bypasses amount calculations for efficiency
     */
    function transfer(
        IERC20Custom token,
        address from,
        address to,
        uint256 share
    ) external;

    /*//////////////////////////////////////////////////////////////
                        BALANCE QUERIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves account's vault share balance
     * @param token Token contract to query
     * @param account Address to check
     * @return uint256 Share balance
     * @dev Provides:
     * · Raw share balance
     * · Without conversion
     * · Current state
     *
     * Use toAmount() to convert to token amount
     */
    function balanceOf(
        IERC20Custom token,
        address account
    ) external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                        CONVERSION OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Converts token amount to vault shares
     * @param token Token contract for conversion
     * @param amount Amount of tokens to convert
     * @param roundUp Whether to round up result
     * @return share Equivalent share amount
     * @dev Calculates:
     * · Share equivalent
     * · Based on totals
     * · Handles precision
     *
     * Rounding:
     * true = ceiling (≥)
     * false = floor (≤)
     */
    function toShare(
        IERC20Custom token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    /**
     * @notice Converts vault shares to token amount
     * @param token Token contract for conversion
     * @param share Amount of shares to convert
     * @param roundUp Whether to round up result
     * @return amount Equivalent token amount
     * @dev Calculates:
     * · Token equivalent
     * · Based on totals
     * · Handles precision
     *
     * Rounding:
     * true = ceiling (≥)
     * false = floor (≤)
     */
    function toAmount(
        IERC20Custom token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    /**
     * @notice Gets the list of active controllers
     * @return Array of controller addresses
     */
    function getControllers() external view returns (address[] memory);

    /*//////////////////////////////////////////////////////////////
                            VAULT TOTALS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves vault's total supply tracking
     * @param token Token contract to query
     * @return vaultTotals Rebase struct containing:
     * · elastic: Total token amount
     * · base: Total shares
     * @dev Provides:
     * · Current vault state
     * · Supply tracking
     * · Conversion basis
     *
     * Used for:
     * · Share calculations
     * · Amount conversions
     * · State validation
     */
    function totals(
        IERC20Custom token
    ) external view returns (Rebase memory vaultTotals);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title ILender
 * @dev Interface for lending operations and management
 * @notice Defines the core lending protocol functionality including:
 * 1. Collateral management and borrowing operations
 * 2. Interest rate and fee management
 * 3. Liquidation handling
 * 4. Vault integration
 *
 * The interface is designed to support:
 * · Over-collateralized lending
 * · Dynamic interest rates
 * · Liquidation mechanisms
 * · Fee collection and distribution
 */
interface ILender {
    /*//////////////////////////////////////////////////////////////
                        ADMIN CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Updates the interest rate for borrowing
     * @param newInterestRate New interest rate (scaled by 1e18)
     */
    function changeInterestRate(uint256 newInterestRate) external;

    /**
     * @notice Sets global and per-address borrowing limits
     * @param newBorrowLimit Total borrowing limit for the protocol
     * @param perAddressPart Maximum borrow amount per address
     */
    function changeBorrowLimit(
        uint256 newBorrowLimit,
        uint256 perAddressPart
    ) external;

    /*//////////////////////////////////////////////////////////////
                        CORE LENDING OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Updates protocol state with accrued interest
     */
    function accrue() external;

    /**
     * @notice Updates the exchange rate from the oracle
     */
    function updateExchangeRate() external;

    /**
     * @notice Withdraws accumulated protocol fees
     * @param amountToProvide Amount of fees to withdraw
     */
    function withdrawFees(uint256 amountToProvide) external;

    /*//////////////////////////////////////////////////////////////
                        LIQUIDATION HANDLING
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Liquidates undercollateralized positions
     * @param liquidator Address performing the liquidation
     * @param users Array of user addresses to liquidate
     * @param maxBorrowParts Maximum borrow parts to liquidate per user
     * @param to Address to receive liquidated collateral
     */
    function liquidate(
        address liquidator,
        address[] memory users,
        uint256[] memory maxBorrowParts,
        address to
    ) external;

    /*//////////////////////////////////////////////////////////////
                        VAULT OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Deposits collateral into the vault
     * @param amount Amount of collateral to deposit
     */
    function vaultDepositAddCollateral(uint256 amount) external;

    /**
     * @notice Withdraws borrowed assets from the vault
     * @param msgSender Address initiating the withdrawal
     * @param amount Amount to withdraw
     * @return part Borrow part assigned
     * @return share Share of the vault
     */
    function borrowVaultWithdraw(
        address msgSender,
        uint256 amount
    ) external returns (uint256 part, uint256 share);

    /*//////////////////////////////////////////////////////////////
                        COLLATERAL MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Adds collateral to a lending position
     * @param to Address to credit the collateral
     * @param skim True to skim tokens from the contract
     * @param share Amount of shares to add as collateral
     */
    function addCollateral(address to, bool skim, uint256 share) external;

    /**
     * @notice Removes collateral from a lending position
     * @param to Address to receive the removed collateral
     * @param share Amount of shares to remove
     */
    function removeCollateral(address to, uint256 share) external;

    /*//////////////////////////////////////////////////////////////
                        BORROWING OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Borrows assets against deposited collateral
     * @param msgSender Address initiating the borrow
     * @param amount Amount to borrow
     * @return part Borrow part assigned
     * @return share Share of the borrowed amount
     */
    function borrow(
        address msgSender,
        uint256 amount
    ) external returns (uint256 part, uint256 share);

    /**
     * @notice Repays borrowed assets
     * @param payer Address paying the debt
     * @param to Address whose debt to repay
     * @param skim True to skim tokens from the contract
     * @param part Amount of borrow part to repay
     * @return amount Actual amount repaid
     */
    function repay(
        address payer,
        address to,
        bool skim,
        uint256 part
    ) external returns (uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets the oracle contract address
     * @return IOracle Oracle interface
     */
    function oracle() external view returns (IOracle);

    /**
     * @notice Gets interest accrual information
     * @return Last accrual timestamp, accumulated interest, interest per second
     */
    function accrueInfo() external view returns (uint256, uint256, uint256);

    /**
     * @notice Gets the required collateral ratio
     * @return uint256 Collateral ratio (scaled by 1e5)
     */
    function collateralRatio() external view returns (uint256);

    /**
     * @notice Gets the liquidation bonus multiplier
     * @return uint256 Liquidation multiplier (scaled by 1e5)
     */
    function liquidationMultiplier() external view returns (uint256);

    /**
     * @notice Gets total collateral shares in the protocol
     * @return uint256 Total collateral share amount
     */
    function totalCollateralShare() external view returns (uint256);

    /**
     * @notice Gets the vault contract address
     * @return IVault Vault interface
     */
    function vault() external view returns (IVault);

    /**
     * @notice Gets the fee recipient address
     * @return address Fee recipient
     */
    function feeTo() external view returns (address);

    /**
     * @notice Gets the collateral token address
     * @return IERC20Custom Collateral token interface
     */
    function collateral() external view returns (IERC20Custom);

    /**
     * @notice Gets total borrow state
     * @return Rebase Total borrow information
     */
    function totalBorrow() external view returns (Rebase memory);

    /**
     * @notice Gets user's borrow part
     * @param account User address
     * @return uint256 User's borrow part
     */
    function userBorrowPart(address account) external view returns (uint256);

    /**
     * @notice Gets user's collateral share
     * @param account User address
     * @return uint256 User's collateral share
     */
    function userCollateralShare(
        address account
    ) external view returns (uint256);

    /**
     * @notice Gets protocol borrowing limits
     * @return total Total protocol borrow limit
     * @return borrowPartPerAddress Per-address borrow limit
     */
    function borrowLimit()
        external
        view
        returns (uint256 total, uint256 borrowPartPerAddress);

    /**
     * @notice Gets the nUSD token address
     * @return IERC20Custom nUSD token interface
     */
    function nusd() external view returns (IERC20Custom);

    /**
     * @notice Gets all accounts with active positions
     * @return address[] Array of account addresses
     */
    function accounts() external view returns (address[] memory);

    /**
     * @notice Gets the collateral precision factor
     * @return uint256 Collateral precision
     */
    function collateralPrecision() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title ILenderOwner
 * @dev Interface for protocol-level lender management and configuration
 * @notice Defines functionality for:
 * 1. Interest rate management
 * 2. Borrow limit control
 * 3. Risk parameter adjustment
 */
interface ILenderOwner {
    /*//////////////////////////////////////////////////////////////
                        INTEREST MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Updates lender's interest rate configuration
     * @param lender The lender contract to modify
     * @param newInterestRate New interest rate value in basis points
     * @dev Controls:
     * · Interest accrual
     * · Yield generation
     * · Protocol revenue
     *
     * Requirements:
     * · Caller is authorized
     * · Rate within bounds
     * · Valid lender contract
     */
    function changeInterestRate(
        ILender lender,
        uint256 newInterestRate
    ) external;

    /*//////////////////////////////////////////////////////////////
                        LIMIT MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Updates lender's borrowing constraints
     * @param lender The lender contract to modify
     * @param newBorrowLimit New total protocol borrow limit
     * @param perAddressPart Maximum borrow limit per address
     * @dev Manages:
     * · Protocol exposure
     * · Individual limits
     * · Risk thresholds
     *
     * Requirements:
     * · Caller is authorized
     * · Valid limits
     * · perAddressPart <= newBorrowLimit
     *
     * Security:
     * · Prevents overleveraging
     * · Controls risk exposure
     * · Ensures protocol stability
     */
    function changeBorrowLimit(
        ILender lender,
        uint256 newBorrowLimit,
        uint256 perAddressPart
    ) external;

    /*//////////////////////////////////////////////////////////////
                        DEPRECATION MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Checks if a lender contract is deprecated
     * @param lender The lender address to check
     * @return bool True if the lender is deprecated, false otherwise
     * @dev Used to:
     * · Prevent operations on deprecated markets
     * · Control market lifecycle
     * · Manage protocol upgrades
     *
     * Security:
     * · Read-only function
     * · No state modifications
     * · Access control not required
     */
    function deprecated(address lender) external view returns (bool);

    /**
     * @notice Checks if a lender contract is in manual mode
     * @param lender The lender address to check
     * @return bool True if the lender is in manual mode, false otherwise
     * @dev Used to:
     * · Determine if borrow limits are managed manually
     * · Control automatic interest rate adjustments
     *
     * Security:
     * · Read-only function
     * · No state modifications
     * · Access control not required
     */
    function manual(address lender) external view returns (bool);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IMarketLens
 * @dev Interface for viewing and analyzing lending market data
 * @notice Provides functionality for:
 * 1. Market size analysis
 * 2. Borrowing metrics
 * 3. Risk assessment data
 */
interface IMarketLens {
    /*//////////////////////////////////////////////////////////////
                            MARKET METRICS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Calculates total borrowed amount from a specific lending market
     * @param lender Address of the lending market to analyze
     * @return uint256 Total borrowed amount in base units
     * @dev Aggregates:
     * · Active loan positions
     * · Accrued interest
     * · Pending liquidations
     *
     * Used for:
     * · Market size analysis
     * · Risk assessment
     * · Protocol health monitoring
     */
    function getTotalBorrowed(ILender lender) external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IMiscHelper
 * @dev Interface for miscellaneous helper functions across the protocol
 * @notice Provides comprehensive helper methods for:
 * 1. Protocol configuration and parameter management
 * 2. Floor token operations
 * 3. Staked nUSD token management
 * 4. PSM (Peg Stability Module) operations
 * 5. Lending operations including borrowing and repayment
 * 6. System-wide view functions
 *
 * This interface acts as a central utility hub for coordinating
 * various protocol components and simplifying complex operations
 */
interface IMiscHelper {
    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Sets the supply hanging calculator contract
     * @param supplyHangingCalculator_ New calculator contract address
     * @dev Used for calculating supply adjustments
     */
    function setSupplyHangingCalculator(
        ISupplyHangingCalculator supplyHangingCalculator_
    ) external;

    /**
     * @notice Sets core protocol parameters and contract addresses
     * @param repayHelper_ Repayment helper contract
     * @param liquidationHelper_ Liquidation helper contract
     * @param dynamicInterestRate_ Interest rate calculator
     * @param feesDistributor_ Fee distribution contract
     * @param feesWithdrawer_ Fee withdrawal contract
     * @param lenderOwner_ Lender owner contract
     * @param marketLens_ Market data viewer contract
     * @dev Updates all main protocol component addresses
     */
    function setParameters(
        IRepayHelper repayHelper_,
        ILiquidationHelper liquidationHelper_,
        IDynamicInterestRate dynamicInterestRate_,
        IFeesDistributor feesDistributor_,
        IFeesWithdrawer feesWithdrawer_,
        ILenderOwner lenderOwner_,
        IMarketLens marketLens_
    ) external;

    /**
     * @notice Sets the list of active lender contracts
     * @param lenders_ Array of lender addresses
     * @dev Updates the protocol's lending markets
     */
    function setLenders(ILender[] memory lenders_) external;

    /**
     * @notice Sets the list of PSM contracts
     * @param pegStabilityModules_ Array of PSM addresses
     * @dev Updates available stablecoin PSM modules
     */
    function setPegStabilityModules(
        IPSM[] memory pegStabilityModules_
    ) external;

    /*//////////////////////////////////////////////////////////////
                        FLOOR TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Deposits Floor tokens into the protocol
     * @param amount Amount of Floor tokens to deposit
     */
    function depositFloor(uint256 amount) external;

    /**
     * @notice Refunds Floor tokens from the protocol
     * @param amount Amount of Floor tokens to refund
     */
    function refundFloor(uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                        STAKED nUSD OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Deposits nUSD tokens for staking
     * @param amount Amount of nUSD to stake
     */
    function depositStakednUSD(uint256 amount) external;

    /**
     * @notice Withdraws staked nUSD tokens
     * @param amount Amount of staked nUSD to withdraw
     */
    function withdrawStakednUSD(uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                            PSM OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Swaps nUSD for stablecoin through PSM
     * @param psm PSM contract to use for swap
     * @param receiver Address to receive stablecoins
     * @param amountnUSD Amount of nUSD to swap
     */
    function psmSwapnUSDForStable(
        IPSM psm,
        address receiver,
        uint256 amountnUSD
    ) external;

    /**
     * @notice Swaps stablecoin for nUSD through PSM
     * @param psm PSM contract to use for swap
     * @param receiver Address to receive nUSD
     * @param amountStable Amount of stablecoin to swap
     */
    function psmSwapStableFornUSD(
        IPSM psm,
        address receiver,
        uint256 amountStable
    ) external;

    /*//////////////////////////////////////////////////////////////
                        LENDING OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Withdraws borrowed tokens from vault
     * @param lender Lender contract to withdraw from
     * @param amount Amount to withdraw
     */
    function lenderBorrowVaultWithdraw(ILender lender, uint256 amount) external;

    /**
     * @notice Executes a borrow operation
     * @param lender Lender contract to borrow from
     * @param amount Amount to borrow
     */
    function lenderBorrow(ILender lender, uint256 amount) external;

    /**
     * @notice Repays borrowed tokens
     * @param lender Lender contract to repay to
     * @param payer Address paying the debt
     * @param to Address receiving any excess
     * @param skim Whether to skim tokens from contract
     * @param part Amount of borrow part to repay
     */
    function lenderRepay(
        ILender lender,
        address payer,
        address to,
        bool skim,
        uint256 part
    ) external;

    /**
     * @notice Executes liquidation for multiple users
     * @param lender Lender contract to liquidate from
     * @param liquidator Address performing liquidation
     * @param users Array of addresses to liquidate
     * @param maxBorrowParts Maximum borrow parts to liquidate per user
     * @param to Address to receive liquidated assets
     */
    function lenderLiquidate(
        ILender lender,
        address liquidator,
        address[] memory users,
        uint256[] memory maxBorrowParts,
        address to
    ) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns current APR for staked nUSD
     * @return uint256 Annual percentage rate
     */
    function aprStakednUSD() external view returns (uint256);

    /**
     * @notice Returns repayment helper contract
     */
    function repayHelper() external view returns (IRepayHelper);

    /**
     * @notice Returns liquidation helper contract
     */
    function liquidationHelper() external view returns (ILiquidationHelper);

    /**
     * @notice Returns dynamic interest rate calculator
     */
    function dynamicInterestRate() external view returns (IDynamicInterestRate);

    /**
     * @notice Returns floor token contract
     */
    function floor() external view returns (IFloor);

    /**
     * @notice Returns fees distributor contract
     */
    function feesDistributor() external view returns (IFeesDistributor);

    /**
     * @notice Returns fees withdrawer contract
     */
    function feesWithdrawer() external view returns (IFeesWithdrawer);

    /**
     * @notice Returns lender contract at specified index
     * @param index Position in lenders array
     */
    function lenders(uint256 index) external view returns (ILender);

    /**
     * @notice Returns total number of lender contracts
     */
    function lendersLength() external view returns (uint256);

    /**
     * @notice Returns lender owner contract
     */
    function lenderOwner() external view returns (ILenderOwner);

    /**
     * @notice Returns market lens contract
     */
    function marketLens() external view returns (IMarketLens);

    /**
     * @notice Returns PSM contract at specified index
     * @param index Position in PSM array
     */
    function pegStabilityModules(uint256 index) external view returns (IPSM);

    /**
     * @notice Returns total number of PSM contracts
     */
    function pegStabilityModulesLength() external view returns (uint256);

    /**
     * @notice Returns staked nUSD token contract
     */
    function stnUSD() external view returns (IStakednUSD);

    /**
     * @notice Returns supply hanging calculator contract
     */
    function supplyHangingCalculator()
        external
        view
        returns (ISupplyHangingCalculator);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IRepayHelper
 * @dev Interface for streamlined loan repayment operations and management
 * @notice Defines functionality for:
 * 1. Loan repayment processing
 * 2. Multi-loan management
 * 3. Helper contract integration
 * 4. Token interactions
 */
interface IRepayHelper {
    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                        REPAYMENT OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Processes partial loan repayment
     * @param lender Address of the lending contract
     * @param to Address whose loan is being repaid
     * @param amount Amount to repay in base units
     * @return part Share of the loan repaid
     * @dev Handles:
     * · Token transfers
     * · Loan accounting
     * · Share calculations
     *
     * Requirements:
     * · Amount > 0
     * · Sufficient balance
     * · Valid addresses
     */
    function repayAmount(
        ILender lender,
        address to,
        uint256 amount
    ) external returns (uint256 part);

    /**
     * @notice Processes complete loan repayment
     * @param lender Address of the lending contract
     * @param to Address whose loan is being repaid
     * @return amount Total amount repaid in base units
     * @dev Manages:
     * · Full debt calculation
     * · Complete repayment
     * · Account settlement
     *
     * Effects:
     * · Clears entire debt
     * · Updates balances
     * · Emits events
     */
    function repayTotal(
        ILender lender,
        address to
    ) external returns (uint256 amount);

    /**
     * @notice Processes multiple complete loan repayments
     * @param lender Address of the lending contract
     * @param tos Array of addresses whose loans are being repaid
     * @return amount Total amount repaid across all loans
     * @dev Executes:
     * · Batch processing
     * · Multiple settlements
     * · Aggregate accounting
     *
     * Optimizations:
     * · Gas efficient
     * · Bulk processing
     * · Single transaction
     */
    function repayTotalMultiple(
        ILender lender,
        address[] calldata tos
    ) external returns (uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves nUSD token contract
     * @return IERC20Custom Interface of the nUSD token
     * @dev Used for:
     * · Token operations
     * · Balance checks
     * · Allowance verification
     */
    function nusd() external view returns (IERC20Custom);

    /**
     * @notice Retrieves helper contract
     * @return IMiscHelper Interface of the helper contract
     * @dev Provides:
     * · Helper functionality
     * · Integration access
     * · Utility methods
     */
    function helper() external view returns (IMiscHelper);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title ILiquidationHelper
 * @dev Interface for liquidation assistance operations
 * @notice Defines comprehensive liquidation functionality including:
 * 1. Direct liquidation execution
 * 2. Liquidation amount calculations
 * 3. Position health checks
 * 4. Preview and simulation functions
 *
 * The helper provides:
 * · Maximum and partial liquidation support
 * · Customizable recipient addresses
 * · Pre-execution liquidation simulations
 * · Automated nUSD amount calculations
 */
interface ILiquidationHelper {
    /*//////////////////////////////////////////////////////////////
                            CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    /*//////////////////////////////////////////////////////////////
                        LIQUIDATION EXECUTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Liquidates maximum possible amount for an account
     * @param lender Address of the lending contract
     * @param account Address to be liquidated
     * @return collateralAmount Amount of collateral received
     * @return adjustedBorrowPart Adjusted borrow amount after liquidation
     * @return requirednUSDAmount nUSD tokens needed to execute liquidation
     * @dev Automatically calculates maximum liquidatable amount
     */
    function liquidateMax(
        ILender lender,
        address account
    )
        external
        returns (
            uint256 collateralAmount,
            uint256 adjustedBorrowPart,
            uint256 requirednUSDAmount
        );

    /**
     * @notice Liquidates specific amount for an account
     * @param lender Address of the lending contract
     * @param account Address to be liquidated
     * @param borrowPart Amount of borrow position to liquidate
     * @return collateralAmount Amount of collateral received
     * @return adjustedBorrowPart Adjusted borrow amount after liquidation
     * @return requirednUSDAmount nUSD tokens needed to execute liquidation
     * @dev Validates borrowPart against maximum liquidatable amount
     */
    function liquidate(
        ILender lender,
        address account,
        uint256 borrowPart
    )
        external
        returns (
            uint256 collateralAmount,
            uint256 adjustedBorrowPart,
            uint256 requirednUSDAmount
        );

    /*//////////////////////////////////////////////////////////////
                    LIQUIDATION WITH CUSTOM RECIPIENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Liquidates maximum amount and sends to specified recipient
     * @param lender Address of the lending contract
     * @param account Address to be liquidated
     * @param recipient Address to receive liquidated assets
     * @dev Combines max liquidation with custom recipient
     */
    function liquidateMaxTo(
        ILender lender,
        address account,
        address recipient
    ) external;

    /**
     * @notice Liquidates specific amount and sends to specified recipient
     * @param lender Address of the lending contract
     * @param account Address to be liquidated
     * @param recipient Address to receive liquidated assets
     * @param borrowPart Amount of borrow position to liquidate
     * @dev Combines partial liquidation with custom recipient
     */
    function liquidateTo(
        ILender lender,
        address account,
        address recipient,
        uint256 borrowPart
    ) external;

    /*//////////////////////////////////////////////////////////////
                        LIQUIDATION PREVIEWS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Previews maximum possible liquidation amounts
     * @param lender Address of the lending contract
     * @param account Address to check
     * @return liquidatable Whether the account can be liquidated
     * @return requirednUSDAmount nUSD tokens needed for liquidation
     * @return adjustedBorrowPart Final borrow amount after liquidation
     * @return returnedCollateralAmount Collateral amount to be received
     * @dev Simulates liquidation without executing
     */
    function previewMaxLiquidation(
        ILender lender,
        address account
    )
        external
        view
        returns (
            bool liquidatable,
            uint256 requirednUSDAmount,
            uint256 adjustedBorrowPart,
            uint256 returnedCollateralAmount
        );

    /**
     * @notice Previews specific liquidation amounts
     * @param lender Address of the lending contract
     * @param account Address to check
     * @param borrowPart Amount of borrow position to liquidate
     * @return liquidatable Whether the account can be liquidated
     * @return requirednUSDAmount nUSD tokens needed for liquidation
     * @return adjustedBorrowPart Final borrow amount after liquidation
     * @return returnedCollateralAmount Collateral amount to be received
     * @dev Simulates partial liquidation without executing
     */
    function previewLiquidation(
        ILender lender,
        address account,
        uint256 borrowPart
    )
        external
        view
        returns (
            bool liquidatable,
            uint256 requirednUSDAmount,
            uint256 adjustedBorrowPart,
            uint256 returnedCollateralAmount
        );

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Checks if an account is eligible for liquidation
     * @param lender Address of the lending contract
     * @param account Address to check
     * @return bool True if account can be liquidated
     * @dev Considers collateral ratio and position health
     */
    function isLiquidatable(
        ILender lender,
        address account
    ) external view returns (bool);

    /**
     * @notice Returns the nUSD token contract used for liquidations
     * @return IERC20Custom nUSD token interface
     * @dev nUSD is required to execute liquidations
     */
    function nusd() external view returns (IERC20Custom);

    /**
     * @notice Returns the helper utility contract
     * @return IMiscHelper Helper interface for additional functions
     * @dev Helper provides supporting calculations and checks
     */
    function helper() external view returns (IMiscHelper);
}
pragma solidity >=0.8.24 <0.9.0;

interface IBaseContracts {
    struct CoreTokens {
        IERC20Token nusd;
        IERC20TokenRebase niv;
        IStakednUSD stnUSD;
        IVoteEscrowedNIV veNIV;
    }
    struct PSMContracts {
        IPSM psmCircle;
        IPSM psmTether;
        IStableOwner stableOwner;
    }
    struct OracleContracts {
        IOracle oracleChainlink;
        IOracle oracleFloorPrice;
    }
    struct HelperContracts {
        IMiscHelper helper;
        ILiquidationHelper liquidationHelper;
        IRepayHelper repayHelper;
        IMarketLens marketLens;
    }
    error ZeroAddress();
    error ContractAlreadySet();

    // Struct getters
    function coreTokens() external view returns (CoreTokens memory);

    function psmContracts() external view returns (PSMContracts memory);

    function oracleContracts() external view returns (OracleContracts memory);

    function helperContracts() external view returns (HelperContracts memory);

    // Individual contract getters
    function nusdProvider() external view returns (InUSDProvider);

    function feesDistributor() external view returns (IFeesDistributor);

    function feesWithdrawer() external view returns (IFeesWithdrawer);

    function floor() external view returns (IFloor);

    function lenderOwner() external view returns (ILenderOwner);

    function minter() external view returns (IMinter);

    function supplyCalculator()
        external
        view
        returns (ISupplyHangingCalculator);

    function vault() external view returns (IVault);

    function dynamicInterestRate() external view returns (IDynamicInterestRate);

    // Convenience getters for struct members
    function nusd() external view returns (IERC20Token);

    function niv() external view returns (IERC20TokenRebase);

    function stnUSD() external view returns (IStakednUSD);

    function veNIV() external view returns (IVoteEscrowedNIV);

    function psmCircle() external view returns (IPSM);

    function psmTether() external view returns (IPSM);

    function stableOwner() external view returns (IStableOwner);

    function oracleChainlink() external view returns (IOracle);

    function oracleFloorPrice() external view returns (IOracle);

    function helper() external view returns (IMiscHelper);

    function liquidationHelper() external view returns (ILiquidationHelper);

    function repayHelper() external view returns (IRepayHelper);

    function marketLens() external view returns (IMarketLens);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title nUSD Token
 * @dev Controlled-supply ERC20 token for protocol operations
 * @notice Core protocol token with supply management features
 */
contract nUSD is Context, Ownable, IERC20Token, IERC20Errors {
    /*//////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @notice Token name
    string private _name;
    /// @notice Token symbol
    string private _symbol;
    /// @notice Number of decimals for token precision
    /// @dev Immutable for gas optimization
    uint8 private immutable _decimals;
    /// @notice Maximum token supply cap
    /// @dev Zero means unlimited supply
    uint256 private immutable _maxSupply;
    /// @notice Current total supply of tokens
    uint256 private _totalSupply;
    /// @notice Mapping of account balances
    /// @dev account => balance
    mapping(address => uint256) private _balances;
    /// @notice Mapping of account allowances
    /// @dev owner => spender => amount
    mapping(address => mapping(address spender => uint256)) private _allowances;
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Error thrown when attempting to exceed maximum supply
    error MaxSupplyReached();
    /// @notice Error thrown when a zero address is provided
    error ZeroAddress();

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes token with metadata and ownership
     * @param name_ Name of the token
     * @param symbol_ Symbol of the token
     * @param decimals_ Number of decimals for token precision
     * @param maxSupply_ Maximum token supply (0 for unlimited)
     * @param baseContracts_ BaseContracts instance for protocol integration
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxSupply_,
        IBaseContracts baseContracts_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _maxSupply = maxSupply_;
        IStableOwner stableOwner_ = baseContracts_.stableOwner();
        _ensureNonzeroAddress(address(stableOwner_));
        transferOwnership(address(stableOwner_));
    }

    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Creates new tokens
     * @param to Address to receive the minted tokens
     * @param value Amount of tokens to mint
     */
    function mint(address to, uint256 value) external override onlyOwner {
        if (_maxSupply != 0) {
            if (totalSupply() + value > _maxSupply) {
                revert MaxSupplyReached();
            }
        }
        _mint(to, value);
    }

    /**
     * @notice Destroys existing tokens
     * @param from Address to burn tokens from
     * @param value Amount of tokens to burn
     */
    function burn(address from, uint256 value) external override onlyOwner {
        _burn(from, value);
    }

    /**
     * @notice Transfers tokens to a specified address
     * @param to Address to transfer to
     * @param value Amount to transfer
     * @return success Always true (reverts on failure)
     */
    function transfer(address to, uint256 value) external returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @notice Approves address to spend tokens
     * @param spender Address authorized to spend
     * @param value Amount authorized to spend
     * @return success Always true (reverts on failure)
     */
    function approve(address spender, uint256 value) external returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @notice Transfer tokens from one address to another
     * @param from Address to transfer from
     * @param to Address to transfer to
     * @param value Amount to transfer
     * @return success Always true (reverts on failure)
     *
     * Requirements:
     * · Valid sender and recipient addresses
     * · Sufficient allowance
     * · Sufficient balance
     *
     * Effects:
     * · Decreases allowance
     * · Updates balances
     * · Emits Transfer event
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Returns the name of the token
    function name() external view returns (string memory) {
        return _name;
    }

    /// @notice Returns the symbol of the token
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /// @notice Returns the number of decimals for token precision
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /// @notice Returns the maximum supply cap of the token
    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    /// @notice Returns the balance of a specific account
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /// @notice Returns the current total supply of tokens
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Returns the amount of tokens approved for a spender
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /*//////////////////////////////////////////////////////////////
                        PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Performs token transfer between accounts
     * @param from Source address
     * @param to Destination address
     * @param value Amount to transfer
     *
     * Requirements:
     * · Valid addresses
     * · Sufficient balance
     */
    function _transfer(address from, address to, uint256 value) private {
        if (from == address(0)) revert ERC20InvalidSender(address(0));
        if (to == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(from, to, value);
    }

    /**
     * @dev Updates balances for transfer operations
     * @param from Source address
     * @param to Destination address
     * @param value Amount to transfer
     *
     * Requirements:
     * · Valid addresses
     * · Sufficient balance
     *
     * Effects:
     * · Updates balances
     * · Updates total supply for mint/burn
     * · Emits Transfer event
     */
    function _update(address from, address to, uint256 value) private {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates new tokens
     * @param account Recipient address
     * @param value Amount to mint
     *
     * Requirements:
     * · Valid recipient address
     */
    function _mint(address account, uint256 value) private {
        if (account == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys existing tokens
     * @param account Address to burn from
     * @param value Amount to burn
     *
     * Requirements:
     * · Valid source address
     * · Sufficient balance
     */
    function _burn(address account, uint256 value) private {
        if (account == address(0)) revert ERC20InvalidSender(address(0));
        _update(account, address(0), value);
    }

    /**
     * @dev Sets spending allowance
     * @param owner Token owner
     * @param spender Authorized spender
     * @param value Authorized amount
     */
    function _approve(address owner, address spender, uint256 value) private {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Sets spending allowance with event control
     * @param owner Token owner
     * @param spender Authorized spender
     * @param value Authorized amount
     * @param emitEvent Whether to emit Approval event
     *
     * Requirements:
     * · Valid addresses
     *
     * Effects:
     * · Updates allowance
     * · Optionally emits Approval event
     */
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) private {
        if (owner == address(0)) revert ERC20InvalidApprover(address(0));
        if (spender == address(0)) revert ERC20InvalidSpender(address(0));
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Deducts from spender's allowance
     * @param owner Token owner
     * @param spender Authorized spender
     * @param value Amount to deduct
     *
     * Requirements:
     * · Sufficient allowance
     *
     * Effects:
     * · Decreases allowance
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    // Validates that an address is not zero
    function _ensureNonzeroAddress(address addr) private pure {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
    }
}