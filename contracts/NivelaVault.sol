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
 * @title ReentrancyGuard
 * @dev Contract module that helps prevent reentrant calls to a function
 * @notice This module is used through inheritance. It will make available the modifier
 * `nonReentrant`, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 */
abstract contract ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Guard state constants
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    /// @notice Current state of the guard
    uint256 private _status;
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    error ReentrantCall();
    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes the contract by setting the initial reentrancy guard state
     */
    constructor() {
        _status = NOT_ENTERED;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Checks if a protected function is currently executing
     * @return True if the contract is in the entered state
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }

    /*//////////////////////////////////////////////////////////////
                            PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Sets guard state before protected function execution
     * @notice Reverts if a reentrant call is detected
     */
    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrantCall();
        }
        _status = ENTERED;
    }

    /**
     * @dev Resets guard state after protected function execution
     */
    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
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
 * @title Controller
 * @dev Contract module that extends Ownable to provide a more flexible authorization
 * system where multiple addresses can be granted controller privileges.
 * @notice This allows for a multi-admin setup where both the owner and authorized
 * controllers can execute protected functions. The owner maintains the ability to
 * add or remove controllers.
 */
abstract contract Controller is Ownable {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Mapping of addresses to their controller status
    mapping(address => bool) public controllers;
    /// @notice Number of active controllers (excluding owner)
    uint256 private _numControllers;
    /// @notice Array of controller addresses
    address[] private _controllerList;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when a new controller is authorized
    event ControllerAdded(address indexed controller);
    /// @notice Emitted when a controller's authorization is revoked
    event ControllerRemoved(address indexed controller);
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Thrown when a non-controller tries to access a protected function
    error SignerIsNotController();
    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Restricts function access to authorized controllers and owner
     * @dev Reverts with SignerIsNotController if caller lacks authorization
     */
    modifier onlyController() {
        if (!isController(_msgSender())) {
            revert SignerIsNotController();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Adds a new controller
     * @dev Only the owner can add new controllers
     * @param controller Address to be granted controller privileges
     */
    function addController(address controller) external onlyOwner {
        if (!controllers[controller] && controller != owner()) {
            controllers[controller] = true;
            _numControllers++;
            _controllerList.push(controller);
            emit ControllerAdded(controller);
        }
    }

    /**
     * @notice Removes a controller
     * @dev Only the owner can remove controllers
     * @param controller Address to have controller privileges revoked
     */
    function removeController(address controller) external onlyOwner {
        if (controllers[controller]) {
            controllers[controller] = false;
            uint256 length = _controllerList.length;
            for (uint256 i = 0; i < length; i++) {
                if (_controllerList[i] == controller) {
                    _controllerList[i] = _controllerList[length - 1];
                    _controllerList.pop();
                    break;
                }
            }
            _numControllers--;
            emit ControllerRemoved(controller);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Checks if an address has controller privileges
     * @dev Returns true if the address is either the owner or an authorized controller
     * @param controller Address to check for authorization
     * @return True if the address has controller privileges
     */
    function isController(address controller) public view returns (bool) {
        return controller == owner() || controllers[controller];
    }

    /**
     * @notice Gets the number of controllers excluding the owner
     * @return The number of active controllers (excluding owner)
     */
    function numControllers() public view returns (uint256) {
        return _numControllers;
    }

    /**
     * @notice Gets the list of active controllers
     * @return Array of controller addresses
     */
    function getControllers() public view virtual returns (address[] memory) {
        return _controllerList;
    }
}
pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
pragma solidity ^0.8.20;

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
pragma solidity ^0.8.20;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title NivelaVault
 * @dev Token vault with rebase and share tracking
 * @notice Multi-token vault with share accounting
 */
contract NivelaVault is Controller, ReentrancyGuard {
    using AuxRebase for Rebase;
    /*//////////////////////////////////////////////////////////////
                        CONSTANTS & STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Minimum share balance to prevent dust accumulation
    /// @dev Prevents extremely small share balances that could cause computational issues
    uint256 private constant MINIMUM_SHARE_BALANCE = 1000;
    /// @notice Tracks total rebase information for each token
    /// @dev Maps token address to its total rebase state
    mapping(IERC20Custom => Rebase) public totals;
    /// @notice Tracks individual account balances for each token
    /// @dev Nested mapping: token address → account address → share balance
    mapping(IERC20Custom => mapping(address => uint256)) public balanceOf;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when tokens are deposited into the vault
    event Deposited(
        IERC20Custom indexed token,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 share
    );
    /// @notice Emitted when tokens are withdrawn from the vault
    event Withdrawn(
        IERC20Custom indexed token,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 share
    );
    /// @notice Emitted when shares are transferred between accounts
    event Transferred(
        IERC20Custom indexed token,
        address indexed from,
        address indexed to,
        uint256 share
    );
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Thrown when an operation would result in an empty vault
    error CannotBeEmpty();
    /// @notice Thrown when an invalid skim operation is attempted
    error InvalidSkim();
    /// @notice Thrown when an unauthorized account attempts an action
    error NotAllowed(address msgSender, address from);
    /// @notice Thrown when no tokens are available for an operation
    error NoTokens();
    /// @notice Thrown when a receiver address is not set
    error ReceiverNotSet();
    /*//////////////////////////////////////////////////////////////
                            ACCESS CONTROL
    //////////////////////////////////////////////////////////////*/
    /// @notice Restricts actions to authorized accounts
    /// @dev Allows actions from:
    /// · The account itself
    /// · The vault contract
    /// · Authorized controllers
    modifier allowed(address from) {
        if (
            from != _msgSender() &&
            from != address(this) &&
            !isController(_msgSender())
        ) {
            revert NotAllowed(_msgSender(), from);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /// @notice Initializes the vault with default configuration
    constructor() {
        _configure();
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Deposits tokens into the vault
     * @param token_ Token to deposit
     * @param from Source address of tokens
     * @param to Recipient address for shares
     * @param amount Amount of tokens to deposit
     * @param share Optional share amount to deposit
     *
     * @dev Flexible deposit mechanism supporting:
     * · Automatic share calculation
     * · Minimum share balance enforcement
     * · Skim and direct deposit modes
     *
     * Requirements:
     * · Non-zero receiver address
     * · Valid token and amount
     * · Sufficient token balance
     *
     * Effects:
     * · Updates share and total balances
     * · Transfers tokens to vault
     * · Emits Deposited event
     */
    function deposit(
        IERC20Custom token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    )
        external
        nonReentrant
        allowed(from)
        returns (uint256 amountIn, uint256 shareIn)
    {
        if (to == address(0)) revert ReceiverNotSet();
        IERC20Custom token = token_;
        _onBeforeDeposit(token, from, to, amount, share);
        Rebase memory total = totals[token];
        if (total.elastic == 0 && token.totalSupply() == 0) revert NoTokens();
        if (share == 0) {
            share = total.toBase(amount, false);
            if (total.base + share < MINIMUM_SHARE_BALANCE) {
                return (0, 0);
            }
        } else {
            amount = total.toElastic(share, true);
        }
        if (
            from == address(this) &&
            amount > _tokenBalanceOf(token) - total.elastic
        ) {
            revert InvalidSkim();
        }
        balanceOf[token][to] += share;
        total.base += share;
        total.elastic += amount;
        totals[token] = total;
        // Only transfer if the source is not the vault itself
        if (from != address(this)) {
            SafeERC20.safeTransferFrom(
                IERC20(address(token)),
                from,
                address(this),
                amount
            );
        }
        emit Deposited(token, from, to, amount, share);
        return (amount, share);
    }

    /*//////////////////////////////////////////////////////////////
                        WITHDRAWAL MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Withdraws tokens from the vault
     * @param token_ Token to withdraw
     * @param from Source address of shares
     * @param to Recipient address for tokens
     * @param amount Optional token amount to withdraw
     * @param share Share amount to withdraw
     *
     * @dev Flexible withdrawal mechanism supporting:
     * · Automatic amount calculation
     * · Minimum share balance preservation
     *
     * Requirements:
     * · Non-zero receiver address
     * · Sufficient share balance
     * · Maintains minimum share balance
     *
     * Effects:
     * · Updates share and total balances
     * · Transfers tokens from vault
     * · Emits Withdrawn event
     */
    function withdraw(
        IERC20Custom token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    )
        external
        nonReentrant
        allowed(from)
        returns (uint256 amountOut, uint256 shareOut)
    {
        if (to == address(0)) revert ReceiverNotSet();
        IERC20Custom token = token_;
        Rebase memory total = totals[token];
        if (share == 0) {
            share = total.toBase(amount, true);
        } else {
            amount = total.toElastic(share, false);
        }
        balanceOf[token][from] -= share;
        total.elastic -= amount;
        total.base -= share;
        if (total.base > 0 && total.base < MINIMUM_SHARE_BALANCE) {
            revert CannotBeEmpty();
        }
        totals[token] = total;
        SafeERC20.safeTransfer(IERC20(address(token)), to, amount);
        emit Withdrawn(token, from, to, amount, share);
        return (amount, share);
    }

    /*//////////////////////////////////////////////////////////////
                         TRANSFER MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Transfers shares between addresses
     * @param token Token to transfer
     * @param from Source address
     * @param to Recipient address
     * @param share Share amount to transfer
     *
     * @dev Allows direct share transfers with:
     * · Access control
     * · Zero-address prevention
     *
     * Requirements:
     * · Sufficient share balance
     * · Non-zero receiver address
     *
     * Effects:
     * · Updates account balances
     * · Emits Transferred event
     */
    function transfer(
        IERC20Custom token,
        address from,
        address to,
        uint256 share
    ) external nonReentrant allowed(from) {
        if (to == address(0)) revert ReceiverNotSet();
        balanceOf[token][from] -= share;
        balanceOf[token][to] += share;
        emit Transferred(token, from, to, share);
    }

    /**
     * @notice Transfers shares to multiple recipients
     * @param token Token to transfer
     * @param from Source address
     * @param tos Recipient addresses
     * @param shares Share amounts to transfer
     *
     * @dev Batch transfer mechanism supporting:
     * · Multiple recipient transfers
     * · Efficient share distribution
     *
     * Requirements:
     * · Sufficient total share balance
     * · Non-zero first receiver address
     *
     * Effects:
     * · Updates multiple account balances
     * · Emits multiple Transferred events
     */
    function transferMultiple(
        IERC20Custom token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) external nonReentrant allowed(from) {
        if (tos[0] == address(0)) revert ReceiverNotSet();
        uint256 totalAmount;
        uint256 len = tos.length;
        for (uint256 i; i < len; i++) {
            address to = tos[i];
            balanceOf[token][to] += shares[i];
            totalAmount += shares[i];
            emit Transferred(token, from, to, shares[i]);
        }
        balanceOf[token][from] -= totalAmount;
    }

    /*//////////////////////////////////////////////////////////////
                         CONVERSION UTILITIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Converts token amount to shares
     * @param token Token to convert
     * @param amount Token amount to convert
     * @param roundUp Whether to round up the share calculation
     * @return share Calculated share amount
     *
     * @dev Precise share calculation based on current rebase state
     */
    function toShare(
        IERC20Custom token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share) {
        share = totals[token].toBase(amount, roundUp);
    }

    /**
     * @notice Converts shares to token amount
     * @param token Token to convert
     * @param share Share amount to convert
     * @param roundUp Whether to round up the amount calculation
     * @return amount Calculated token amount
     *
     * @dev Precise amount calculation based on current rebase state
     */
    function toAmount(
        IERC20Custom token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount) {
        amount = totals[token].toElastic(share, roundUp);
    }

    /*//////////////////////////////////////////////////////////////
                         PRIVATE CONFIGURATION HOOKS
    //////////////////////////////////////////////////////////////*/
    /// @notice Optional configuration method for derived contracts
    function _configure() internal virtual {}

    /// @notice Optional pre-deposit hook for derived contracts
    function _onBeforeDeposit(
        IERC20Custom token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) internal virtual {}

    /// @notice Gets the current token balance of the vault
    function _tokenBalanceOf(
        IERC20Custom token
    ) private view returns (uint256 amount) {
        amount = token.balanceOf(address(this));
    }
}