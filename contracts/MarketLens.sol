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
 * @title MathLib
 * @dev Library for safe mathematical operations and array comparisons
 * @notice This library provides utility functions for:
 * 1. Finding maximum/minimum values in arrays
 * 2. Comparing pairs of numbers
 * 3. Safe subtraction with zero floor protection
 */
library MathLib {
    /*//////////////////////////////////////////////////////////////
                            ARRAY OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Finds the maximum value in an array
     * @param values Array of values to compare
     * @return uint256 Maximum value in the array
     * @dev
     * · Assumes array is not empty. First value is used as initial max.
     * · Reverts if input array is empty
     * · O(n) time complexity, where n is array length
     * · Useful for scenarios like tracking highest bid, maximum allocation, etc.
     */
    function max(uint256[] memory values) internal pure returns (uint256) {
        uint256 maxValue = values[0];
        uint256 length = values.length;
        for (uint256 i = 1; i < length; i++) {
            if (values[i] > maxValue) {
                maxValue = values[i];
            }
        }
        return maxValue;
    }

    /**
     * @notice Finds the minimum value in an array
     * @param values Array of values to compare
     * @return uint256 Minimum value in the array
     * @dev
     * · Assumes array is not empty. First value is used as initial min.
     * · Reverts if input array is empty
     * · O(n) time complexity, where n is array length
     * · Useful for scenarios like finding lowest price, minimum threshold, etc.
     */
    function min(uint256[] memory values) internal pure returns (uint256) {
        uint256 minValue = values[0];
        uint256 length = values.length;
        for (uint256 i = 1; i < length; i++) {
            if (values[i] < minValue) {
                minValue = values[i];
            }
        }
        return minValue;
    }

    /*//////////////////////////////////////////////////////////////
                         COMPARISON OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns the larger of two values
     * @param a First value to compare
     * @param b Second value to compare
     * @return uint256 Maximum between a and b
     * @dev Uses ternary operator for gas efficiency
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @notice Returns the smaller of two values
     * @param a First value to compare
     * @param b Second value to compare
     * @return uint256 Minimum between a and b
     * @dev Uses ternary operator for gas efficiency
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /*//////////////////////////////////////////////////////////////
                          ARITHMETIC OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Performs subtraction with a zero floor
     * @param a Value to subtract from
     * @param b Value to subtract
     * @return uint256 Result of (a - b) if a > b, otherwise 0
     * @dev Prevents underflow by returning 0 instead of reverting
     */
    function subWithZeroFloor(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        return a > b ? a - b : 0;
    }
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
 * @title LenderLib
 * @dev Library for lending calculations and position management
 * @notice Provides core lending functions for:
 * 1. Borrow tracking and interest accrual
 * 2. Collateral valuation and position health monitoring
 * 3. Liquidation calculations and solvency checks
 */
library LenderLib {
    using AuxRebase for Rebase;
    /// @notice Precision constants
    uint256 public constant TENK_PRECISION = 10_000;
    uint256 public constant HUNDREDK_PRECISION = 100_000;
    uint256 public constant MANTISSA_ONE = 1e18;

    /*//////////////////////////////////////////////////////////////
                        BORROWING CALCULATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets user's borrowed amount with accrued interest
     * @param lender Lending contract
     * @param user User address
     * @return borrowAmount Current borrowed amount including interest
     * @dev Calculates user's share of total borrowed amount using borrow parts
     */
    function getUserBorrowedAmount(
        ILender lender,
        address user
    ) internal view returns (uint256 borrowAmount) {
        Rebase memory totalBorrow = getTotalBorrowedWithAccruedInterests(
            lender
        );
        if (totalBorrow.base == 0) return 0;
        return
            (lender.userBorrowPart(user) * totalBorrow.elastic) /
            totalBorrow.base;
    }

    /**
     * @notice Calculates total borrowed amount including accrued interest
     * @param lender Lending contract
     * @return totalBorrow Updated total borrow state with accrued interest
     * @dev Interest is calculated based on time elapsed since last accrual
     */
    function getTotalBorrowedWithAccruedInterests(
        ILender lender
    ) internal view returns (Rebase memory totalBorrow) {
        totalBorrow = lender.totalBorrow();
        (uint256 lastAccrued, , uint256 interestPerSecond) = lender
            .accrueInfo();
        uint256 elapsedTime = block.timestamp - lastAccrued;
        if (elapsedTime != 0 && totalBorrow.base != 0) {
            totalBorrow.elastic += ((totalBorrow.elastic *
                interestPerSecond *
                elapsedTime) / MANTISSA_ONE);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        COLLATERAL VALUATION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets current oracle exchange rate for collateral
     * @param lender Lending contract
     * @return uint256 Current exchange rate from oracle
     * @dev Fetches real-time price from oracle for collateral token
     */
    function getOracleExchangeRate(
        ILender lender
    ) internal view returns (uint256) {
        IERC20Custom collateral = lender.collateral();
        IOracle oracle = lender.oracle();
        return oracle.getPrice(address(collateral));
    }

    /**
     * @notice Gets user's collateral amount and USD value
     * @param lender Lending contract
     * @param account User address
     * @return amount Raw collateral token amount
     * @return value Collateral value in USD (scaled by collateralPrecision)
     * @dev Converts share to amount and calculates USD value using oracle price
     */
    function getUserCollateral(
        ILender lender,
        address account
    ) internal view returns (uint256 amount, uint256 value) {
        uint256 collateralPrecision = lender.collateralPrecision();
        IVault vault = lender.vault();
        uint256 share = lender.userCollateralShare(account);
        amount = vault.toAmount(lender.collateral(), share, false);
        value = (amount * getOracleExchangeRate(lender)) / collateralPrecision;
    }

    /*//////////////////////////////////////////////////////////////
                        POSITION MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets detailed position information for a user
     * @param lender Lending contract
     * @param account User address
     * @return ltvBps Loan-to-Value ratio in basis points (10000 = 100%)
     * @return healthFactor Position health factor (1e18 = 100% healthy)
     * @return borrowValue Total borrowed value in USD
     * @return collateralValue Total collateral value in USD
     * @return liquidationPrice Price at which position becomes liquidatable
     * @return collateralAmount Raw amount of collateral deposited
     * @dev All calculations use precise decimal handling with collateralPrecision
     */
    function getUserPositionInfo(
        ILender lender,
        address account
    )
        internal
        view
        returns (
            uint256 ltvBps,
            uint256 healthFactor,
            uint256 borrowValue,
            uint256 collateralValue,
            uint256 liquidationPrice,
            uint256 collateralAmount
        )
    {
        (collateralAmount, collateralValue) = getUserCollateral(
            lender,
            account
        );
        borrowValue = getUserBorrowedAmount(lender, account);
        if (collateralValue > 0) {
            ltvBps = (borrowValue * TENK_PRECISION) / collateralValue;
            uint256 collateralRatio = lender.collateralRatio();
            uint256 collateralPrecision = lender.collateralPrecision();
            liquidationPrice =
                (borrowValue * collateralPrecision ** 2 * HUNDREDK_PRECISION) /
                collateralRatio /
                collateralAmount /
                MANTISSA_ONE;
            healthFactor = MathLib.subWithZeroFloor(
                MANTISSA_ONE,
                ((MANTISSA_ONE ** 2) * liquidationPrice) /
                    getOracleExchangeRate(lender) /
                    collateralPrecision
            );
        }
    }

    /*//////////////////////////////////////////////////////////////
                        LIQUIDATION HANDLING
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Calculates liquidation amounts for a position
     * @param lender Lending contract
     * @param account User address to liquidate
     * @param borrowPart Amount of borrow part to liquidate
     * @return collateralAmount Amount of collateral to receive
     * @return adjustedBorrowPart Final borrow part after adjustments
     * @return requirednUSD Amount of nUSD needed for liquidation
     * @dev Includes liquidation multiplier and precision handling
     */
    function getLiquidationCollateralAndBorrowAmount(
        ILender lender,
        address account,
        uint256 borrowPart
    )
        internal
        view
        returns (
            uint256 collateralAmount,
            uint256 adjustedBorrowPart,
            uint256 requirednUSD
        )
    {
        uint256 exchangeRate = getOracleExchangeRate(lender);
        Rebase memory totalBorrow = getTotalBorrowedWithAccruedInterests(
            lender
        );
        IVault vault = lender.vault();
        uint256 collateralShare = lender.userCollateralShare(account);
        IERC20Custom collateral = lender.collateral();
        uint256 collateralPrecision = lender.collateralPrecision();
        {
            Rebase memory vaultTotals = vault.totals(collateral);
            uint256 maxBorrowPart = (vaultTotals.toElastic(
                collateralShare,
                false
            ) *
                HUNDREDK_PRECISION *
                exchangeRate) /
                lender.liquidationMultiplier() /
                collateralPrecision;
            maxBorrowPart = totalBorrow.toBase(maxBorrowPart, false);
            if (borrowPart > maxBorrowPart) {
                borrowPart = maxBorrowPart;
            }
        }
        requirednUSD = totalBorrow.toElastic(borrowPart, false);
        {
            Rebase memory vaultTotals = vault.totals(collateral);
            collateralShare = vaultTotals.toBase(
                (requirednUSD *
                    lender.liquidationMultiplier() *
                    collateralPrecision) /
                    exchangeRate /
                    HUNDREDK_PRECISION,
                false
            );
            collateralAmount = vault.toAmount(
                collateral,
                collateralShare,
                false
            );
        }
        {
            requirednUSD +=
                ((((requirednUSD * lender.liquidationMultiplier()) /
                    HUNDREDK_PRECISION) - requirednUSD) * 10) /
                100;
            IERC20Custom nusd = lender.nusd();
            requirednUSD = vault.toAmount(
                nusd,
                vault.toShare(nusd, requirednUSD, true),
                true
            );
        }
        adjustedBorrowPart = borrowPart;
    }

    /**
     * @notice Checks if a user's position is solvent
     * @param lender Lending contract
     * @param account User address to check
     * @return bool True if position is solvent, false otherwise
     * @dev A position is solvent if collateral value >= required collateral ratio
     */
    function isSolvent(
        ILender lender,
        address account
    ) internal view returns (bool) {
        IVault vault = lender.vault();
        Rebase memory totalBorrow = getTotalBorrowedWithAccruedInterests(
            lender
        );
        uint256 exchangeRate = getOracleExchangeRate(lender);
        IERC20Custom collateral = lender.collateral();
        uint256 collateralPrecision = lender.collateralPrecision();
        uint256 collateralRatio = lender.collateralRatio();
        uint256 collateralShare = lender.userCollateralShare(account);
        uint256 borrowPart = lender.userBorrowPart(account);
        if (borrowPart == 0) return true;
        if (collateralShare == 0) return false;
        return
            vault.toAmount(
                collateral,
                (collateralShare * collateralRatio) / HUNDREDK_PRECISION,
                false
            ) >=
            (borrowPart * totalBorrow.elastic * collateralPrecision) /
                totalBorrow.base /
                exchangeRate;
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title MarketLens
 * @dev Comprehensive view and analytics contract for lending markets
 * @notice Provides:
 * · Detailed market metrics
 * · User position insights
 * · Lending market analytics
 */
contract MarketLens is Ownable, IMarketLens {
    /*//////////////////////////////////////////////////////////////
                            DATA STRUCTURES
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Represents token amount with USD valuation
     * @param amount Quantity of tokens
     * @param value Equivalent USD value
     *
     * Use Cases:
     * · Collateral tracking
     * · Position valuation
     * · Financial reporting
     */
    struct AmountValue {
        uint256 amount; // Token quantity
        uint256 value; // USD equivalent
    }
    /**
     * @dev Comprehensive market information structure
     * @notice Encapsulates critical market parameters
     *
     * Includes:
     * · Lending market address
     * · Fee structures
     * · Borrowing limits
     * · Collateral metrics
     * · Interest calculations
     */
    struct MarketInfo {
        address lender; // Lending market contract
        uint256 maximumCollateralRatio; // Maximum allowed LTV
        uint256 liquidationFee; // Liquidation penalty
        uint256 interestPerYear; // Annual interest rate
        uint256 marketMaxBorrow; // Total market borrow limit
        uint256 userMaxBorrow; // Per-user borrow limit
        uint256 totalBorrowed; // Current total borrowed amount
        uint256 collateralPrice; // Collateral exchange rate
        AmountValue totalCollateral; // Total market collateral
    }
    /**
     * @dev Detailed user position representation
     * @notice Provides comprehensive user lending position insights
     *
     * Metrics:
     * · Lending market
     * · Loan-to-value ratio
     * · Health factor
     * · Borrowed value
     * · Collateral details
     * · Liquidation parameters
     */
    struct UserPosition {
        address lender; // Lending market
        address account; // User address
        uint256 ltvBps; // Loan-to-value ratio
        uint256 healthFactor; // Position stability indicator
        uint256 borrowValue; // Current borrowed value
        AmountValue collateral; // Collateral position
        uint256 liquidationPrice; // Price triggering liquidation
    }
    /*//////////////////////////////////////////////////////////////
                        MARKET METRIC CALCULATIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Precision constants
    uint256 public constant TENK_PRECISION = 10_000;
    uint256 public constant HUNDREDK_PRECISION = 100_000;

    /**
     * @notice Retrieves maximum collateral ratio
     * @param lender Lending market contract
     * @return collateralRatio Collateral ratio in basis points
     *
     * Calculation:
     * · Converts raw ratio to basis points
     * · Standardizes collateral limit representation
     */
    function getMaximumCollateralRatio(
        ILender lender
    ) public view returns (uint256 collateralRatio) {
        return (lender.collateralRatio() * TENK_PRECISION) / HUNDREDK_PRECISION;
    }

    /**
     * @notice Calculates liquidation fee percentage
     * @param lender Lending market contract
     * @return liquidationFee Liquidation fee in basis points
     *
     * Calculation:
     * · Derives fee from liquidation multiplier
     * · Converts to basis points representation
     */
    function getLiquidationFee(
        ILender lender
    ) public view returns (uint256 liquidationFee) {
        liquidationFee = lender.liquidationMultiplier() - HUNDREDK_PRECISION;
        return (liquidationFee * TENK_PRECISION) / HUNDREDK_PRECISION;
    }

    /**
     * @notice Calculates annual interest rate
     * @param lender Lending market contract
     * @return interestRate Annualized interest percentage
     *
     * Calculation:
     * · Converts per-second interest to yearly rate
     * · Uses precise time-based scaling
     */
    function getInterestPerYear(
        ILender lender
    ) public view returns (uint256 interestRate) {
        (, , uint256 interestPerSecond) = lender.accrueInfo();
        return (interestPerSecond * 100) / 316880879;
    }

    /**
     * @notice Retrieves token balance in vault
     * @param vault Vault contract
     * @param token Token contract
     * @param account User address
     * @return share Token share
     * @return amount Token amount
     *
     *
     * Calculation:
     * · Retrieves token balance from vault
     * · Converts balance to share representation
     */
    function getTokenInVault(
        IVault vault,
        IERC20Custom token,
        address account
    ) public view returns (uint256 share, uint256 amount) {
        share = vault.balanceOf(token, account);
        amount = vault.toAmount(token, share, false);
        return (share, amount);
    }

    /**
     * @notice Retrieves token balance share in vault
     * @param vault Vault contract
     * @param token Token contract
     * @param account User address
     * @return share Token balance share
     *
     * Calculation:
     * · Retrieves token balance share from vault
     */
    function getTokenInVaultShare(
        IVault vault,
        IERC20Custom token,
        address account
    ) public view returns (uint256 share) {
        return (share = vault.balanceOf(token, account));
    }

    /**
     * @notice Retrieves token balance amount in vault
     * @param vault Vault contract
     * @param token Token contract
     * @param account User address
     * @return amount Token balance amount
     *
     * Calculation:
     * · Retrieves token balance from vault
     * · Converts balance to amount representation
     */
    function getTokenInVaultAmount(
        IVault vault,
        IERC20Custom token,
        address account
    ) public view returns (uint256 amount) {
        uint256 share = vault.balanceOf(token, account);
        return (amount = vault.toAmount(token, share, false));
    }

    /**
     * @notice Calculates maximum market borrow limit
     * @param lender Lending market contract
     * @return maxBorrow Maximum market borrow limit
     *
     * Calculation:
     * · Retrieves total borrow limit from lender
     * · Calculates remaining borrow limit
     * · Returns minimum of nusd in vault and remaining borrow limit
     */
    function getMaxMarketBorrowForLender(
        ILender lender
    ) public view returns (uint256 maxBorrow) {
        (uint256 totalBorrowLimit, ) = lender.borrowLimit();
        uint256 nusdInVault = _getnUSDInVault(lender);
        uint256 remainingBorrowLimit = MathLib.subWithZeroFloor(
            totalBorrowLimit,
            getTotalBorrowed(lender)
        );
        return MathLib.min(nusdInVault, remainingBorrowLimit);
    }

    /**
     * @notice Calculates maximum user borrow limit
     * @param lender Lending market contract
     * @return userMaxBorrow Maximum user borrow limit
     *
     * Calculation:
     * · Retrieves total borrow limit and user borrow limit from lender
     * · Calculates remaining borrow limit
     * · Returns minimum of nusd in vault, remaining borrow limit, and user borrow limit
     */
    function getMaxUserBorrowForLender(
        ILender lender
    ) public view returns (uint256 userMaxBorrow) {
        (uint256 totalBorrowLimit, uint256 userBorrowLimit) = lender
            .borrowLimit();
        uint256[] memory values = new uint256[](3);
        values[0] = _getnUSDInVault(lender);
        values[1] = MathLib.subWithZeroFloor(
            totalBorrowLimit,
            getTotalBorrowed(lender)
        );
        values[2] = userBorrowLimit;
        return MathLib.min(values);
    }

    /**
     * @notice Retrieves total borrowed amount
     * @param lender Lending market contract
     * @return totalBorrowed Total borrowed amount
     *
     * Calculation:
     * · Retrieves total borrowed amount from lender
     * · Includes accrued interest
     */
    function getTotalBorrowed(
        ILender lender
    ) public view returns (uint256 totalBorrowed) {
        return LenderLib.getTotalBorrowedWithAccruedInterests(lender).elastic;
    }

    /**
     * @notice Retrieves oracle exchange rate
     * @param lender Lending market contract
     * @return exchangeRate Oracle exchange rate
     *
     * Calculation:
     * · Retrieves oracle exchange rate from lender
     */
    function getOracleExchangeRate(
        ILender lender
    ) public view returns (uint256 exchangeRate) {
        return LenderLib.getOracleExchangeRate(lender);
    }

    /**
     * @notice Retrieves total collateral
     * @param lender Lending market contract
     * @return totalCollateral Total collateral
     *
     * Calculation:
     * · Retrieves total collateral share from lender
     * · Converts share to amount representation
     * · Calculates collateral value using oracle exchange rate
     */
    function getTotalCollateral(
        ILender lender
    ) public view returns (AmountValue memory totalCollateral) {
        IVault vault = lender.vault();
        uint256 collateralPrecision = lender.collateralPrecision();
        uint256 amount = vault.toAmount(
            lender.collateral(),
            lender.totalCollateralShare(),
            false
        );
        uint256 value = (amount * getOracleExchangeRate(lender)) /
            collateralPrecision;
        return AmountValue(amount, value);
    }

    /**
     * @notice Retrieves user borrowed amount
     * @param lender Lending market contract
     * @param account User address
     * @return userBorrowed User borrowed amount
     *
     * Calculation:
     * · Retrieves user borrowed amount from lender
     */
    function getUserBorrowed(
        ILender lender,
        address account
    ) public view returns (uint256 userBorrowed) {
        return LenderLib.getUserBorrowedAmount(lender, account);
    }

    /**
     * @notice Calculates user maximum borrow limit
     * @param lender Lending market contract
     * @param account User address
     * @return maxBorrow User maximum borrow limit
     *
     * Calculation:
     * · Retrieves user collateral value from lender
     * · Calculates maximum borrow limit using collateral ratio
     * · Returns minimum of maximum borrow limit and user borrow limit
     */
    function getUserMaxBorrow(
        ILender lender,
        address account
    ) public view returns (uint256 maxBorrow) {
        (, uint256 value) = LenderLib.getUserCollateral(lender, account);
        maxBorrow =
            (value * getMaximumCollateralRatio(lender)) /
            TENK_PRECISION;
        uint256 borrowed = getUserBorrowed(lender, account);
        return borrowed >= maxBorrow ? 0 : maxBorrow - borrowed;
    }

    /**
     * @notice Retrieves user collateral
     * @param lender Lending market contract
     * @param account User address
     * @return userCollateral User collateral
     *
     * Calculation:
     * · Retrieves user collateral from lender
     */
    function getUserCollateral(
        ILender lender,
        address account
    ) public view returns (AmountValue memory userCollateral) {
        (uint256 amount, uint256 value) = LenderLib.getUserCollateral(
            lender,
            account
        );
        return AmountValue(amount, value);
    }

    /**
     * @notice Retrieves user loan-to-value ratio
     * @param lender Lending market contract
     * @param account User address
     * @return ltvBps User loan-to-value ratio
     *
     * Calculation:
     * · Retrieves user position info from lender
     */
    function getUserLtv(
        ILender lender,
        address account
    ) public view returns (uint256 ltvBps) {
        (ltvBps, , , , , ) = LenderLib.getUserPositionInfo(lender, account);
    }

    /**
     * @notice Calculates user health factor
     * @param lender Lending market contract
     * @param account User address
     * @param isStable Stable or variable borrow
     * @return healthFactor User health factor
     *
     * Calculation:
     * · Retrieves user position info from lender
     * · Calculates health factor using collateral value and borrowed amount
     */
    function getHealthFactor(
        ILender lender,
        address account,
        bool isStable
    ) public view returns (uint256 healthFactor) {
        (, healthFactor, , , , ) = LenderLib.getUserPositionInfo(
            lender,
            account
        );
        return isStable ? healthFactor * 10 : healthFactor;
    }

    /**
     * @notice Retrieves user liquidation price
     * @param lender Lending market contract
     * @param account User address
     * @return liquidationPrice User liquidation price
     *
     * Calculation:
     * · Retrieves user position info from lender
     */
    function getUserLiquidationPrice(
        ILender lender,
        address account
    ) public view returns (uint256 liquidationPrice) {
        (, , , , liquidationPrice, ) = LenderLib.getUserPositionInfo(
            lender,
            account
        );
    }

    /**
     * @notice Retrieves user position
     * @param lender Lending market contract
     * @param account User address
     * @return userPosition User position
     *
     * Calculation:
     * · Retrieves user position info from lender
     * · Calculates user position using collateral value and borrowed amount
     */
    function getUserPosition(
        ILender lender,
        address account
    ) public view returns (UserPosition memory userPosition) {
        (
            uint256 ltvBps,
            uint256 healthFactor,
            uint256 borrowValue,
            uint256 collateralValue,
            uint256 liquidationPrice,
            uint256 collateralAmount
        ) = LenderLib.getUserPositionInfo(lender, account);
        return
            UserPosition(
                address(lender),
                address(account),
                ltvBps,
                healthFactor,
                borrowValue,
                AmountValue({amount: collateralAmount, value: collateralValue}),
                liquidationPrice
            );
    }

    /**
     * @notice Retrieves users' positions
     * @param lender Lending market contract
     * @param users User addresses
     * @return positions Users' positions
     *
     * Calculation:
     * · Retrieves users' position info from lender
     * · Calculates users' positions using collateral value and borrowed amount
     */
    function getUsersPositions(
        ILender lender,
        address[] calldata users
    ) public view returns (UserPosition[] memory positions) {
        uint256 length = users.length;
        positions = new UserPosition[](length);
        for (uint256 i; i < length; i++) {
            positions[i] = getUserPosition(lender, users[i]);
        }
    }

    /**
     * @notice Retrieves market info
     * @param lender Lending market contract
     * @return marketInfo Market info
     *
     * Calculation:
     * · Retrieves market info from lender
     * · Calculates market max borrow and user max borrow
     */
    function getMarketInfoLender(
        ILender lender
    ) public view returns (MarketInfo memory marketInfo) {
        marketInfo = _getMarketInfoLender(lender);
        marketInfo.marketMaxBorrow = getMaxMarketBorrowForLender(lender);
        marketInfo.userMaxBorrow = getMaxUserBorrowForLender(lender);
    }

    /*//////////////////////////////////////////////////////////////
                        PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Calculates maximum market borrow limit
     * @param lender Lending market contract
     * @return maxBorrow Maximum market borrow limit
     *
     * Calculation:
     * · Retrieves nusd in vault
     */
    function _getMaxMarketBorrowForLender(
        ILender lender
    ) private view returns (uint256 maxBorrow) {
        return _getnUSDInVault(lender);
    }

    /**
     * @notice Calculates maximum user borrow limit
     * @param lender Lending market contract
     * @return userMaxBorrow Maximum user borrow limit
     *
     * Calculation:
     * · Retrieves nusd in vault
     */
    function _getMaxUserBorrowForLender(
        ILender lender
    ) private view returns (uint256 userMaxBorrow) {
        return _getnUSDInVault(lender);
    }

    /**
     * @notice Retrieves market info
     * @param lender Lending market contract
     * @return marketInfo Market info
     *
     * Calculation:
     * · Retrieves market info from lender
     */
    function _getMarketInfoLender(
        ILender lender
    ) private view returns (MarketInfo memory marketInfo) {
        return
            MarketInfo({
                lender: address(lender),
                maximumCollateralRatio: getMaximumCollateralRatio(lender),
                liquidationFee: getLiquidationFee(lender),
                interestPerYear: getInterestPerYear(lender),
                marketMaxBorrow: _getMaxMarketBorrowForLender(lender),
                userMaxBorrow: _getMaxUserBorrowForLender(lender),
                totalBorrowed: getTotalBorrowed(lender),
                collateralPrice: getOracleExchangeRate(lender),
                totalCollateral: getTotalCollateral(lender)
            });
    }

    /**
     * @notice Retrieves nusd in vault
     * @param lender Lending market contract
     * @return nusdInVault nusd in vault
     *
     * Calculation:
     * · Retrieves nusd balance from vault
     * · Converts balance to amount representation
     */
    function _getnUSDInVault(
        ILender lender
    ) private view returns (uint256 nusdInVault) {
        IVault vault = lender.vault();
        IERC20Custom nusd = lender.nusd();
        uint256 poolBalance = vault.balanceOf(nusd, address(lender));
        nusdInVault = vault.toAmount(nusd, poolBalance, false);
    }
}