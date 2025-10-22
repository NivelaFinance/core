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

/// @title IOracleApi3Reader Interface
/// @notice Interface for interacting with Api3 Network's Chainlink price feed adapter
interface IOracleApi3Reader {
    /// @notice Get the latest price data from the Chainlink oracle
    /// @return roundId The round ID from the underlying price feed
    /// @return answer The price answer from the oracle
    /// @return startedAt Timestamp of when the round started
    /// @return updatedAt Timestamp of when the round was updated
    /// @return answeredInRound The round ID in which the answer was computed
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    /// @notice Get the number of decimals in the price feed's response
    /// @return The number of decimals used in the price feed
    function decimals() external view returns (uint8);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title OracleChainlink
 * @dev Oracle implementation using Chainlink price feeds with fallback direct prices
 * @notice This contract manages price feeds and provides asset prices
 */
contract OracleChainlink is Ownable, IOracle {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Configuration for token price feeds
     * @param asset Token address to get price for
     * @param feed Chainlink aggregator address
     */
    struct TokenConfig {
        address asset;
        address feed;
    }
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Maps assets to their direct price overrides (in 18 decimals)
    mapping(address => uint256) public prices;
    /// @notice Maps assets to their Chainlink feed configurations
    mapping(address => TokenConfig) public tokenConfigs;
    /// @notice Maximum time (in seconds) before price is considered stale
    uint256 public constant MAX_STALE_PERIOD = 24 hours;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when a token's price feed configuration is set
    event TokenConfigAdded(address indexed asset, address feed);
    /*//////////////////////////////////////////////////////////////
                             CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @dev Thrown when an address parameter is zero
    error ZeroAddress();
    /// @dev Thrown when empty array is provided
    error NegativePrice();
    /// @dev Thrown when token decimals are invalid
    error InvalidDecimals();
    /// @dev Thrown when price is stale or timestamp is invalid
    error InvalidTime();
    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Ensures an address parameter is not zero
     * @param addr Address to validate
     */
    modifier notNullAddress(address addr) {
        if (addr == address(0)) revert ZeroAddress();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Sets configuration for a single token price feed
     * @param tokenConfig Token configuration to set
     */
    function setTokenConfig(
        TokenConfig memory tokenConfig
    )
        external
        notNullAddress(tokenConfig.asset)
        notNullAddress(tokenConfig.feed)
        onlyOwner
    {
        IERC20Custom token = IERC20Custom(tokenConfig.asset);
        uint8 tokenDecimals = token.decimals();
        IOracleApi3Reader feed = IOracleApi3Reader(tokenConfig.feed);
        uint8 feedDecimals = feed.decimals();
        if (tokenDecimals > 18 || feedDecimals > 18) revert InvalidDecimals();
        tokenConfigs[tokenConfig.asset] = tokenConfig;
        emit TokenConfigAdded(tokenConfig.asset, tokenConfig.feed);
    }

    /**
     * @notice Gets the current price for an asset
     * @param asset Asset address to get price for
     * @return uint256 Current price in 18 decimals
     */
    function getPrice(address asset) public view virtual returns (uint256) {
        IERC20Custom token = IERC20Custom(asset);
        uint8 decimals = token.decimals();
        return _getPrice(asset, decimals);
    }

    /*//////////////////////////////////////////////////////////////
                           PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Gets price with decimal adjustment
     * @param asset Asset address to get price for
     * @param decimals Token decimals for normalization
     * @return price Price in 18 decimals
     */
    function _getPrice(
        address asset,
        uint8 decimals
    ) private view returns (uint256 price) {
        uint256 tokenPrice = prices[asset];
        if (tokenPrice != 0) {
            // Direct price override exists, normalize to 18 decimals
            uint8 decimalDelta = 18 - decimals;
            price = tokenPrice * (10 ** decimalDelta);
        } else {
            // No override, get from Chainlink
            price = _getChainlinkPrice(asset);
        }
        return price;
    }

    /**
     * @dev Fetches and validates price from Chainlink feed
     * @param asset Asset address to get price for
     * @return uint256 Normalized price in 18 decimals
     */
    function _getChainlinkPrice(
        address asset
    ) private view notNullAddress(tokenConfigs[asset].asset) returns (uint256) {
        TokenConfig memory tokenConfig = tokenConfigs[asset];
        IOracleApi3Reader feed = IOracleApi3Reader(tokenConfig.feed);
        uint8 decimalDelta = 18 - feed.decimals();
        (, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();
        // Validate price and timestamp
        if (answer <= 0) revert NegativePrice();
        if (block.timestamp < updatedAt) revert InvalidTime();
        uint256 deltaTime;
        unchecked {
            deltaTime = block.timestamp - updatedAt;
        }
        if (deltaTime > MAX_STALE_PERIOD) revert InvalidTime();
        // Normalize to 18 decimals
        return uint256(answer) * (10 ** decimalDelta);
    }
}