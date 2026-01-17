pragma solidity >=0.4.22 <0.9.0;

/**
 * @title Migrations
 * @dev This contract keeps track of the deployment progress of your smart contracts.
 * It is used by frameworks like Truffle to ensure migrations are only run once.
 */
contract Migrations {
    
    // The address that deployed this contract (the administrator)
    address public owner = msg.sender;

    // Stores the ID of the last deployment script that was successfully executed
    uint public last_completed_migration;

    /**
     * @dev Modifier to restrict function access to the contract owner.
     * This prevents unauthorized accounts from changing the migration status.
     */
    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        // The underscore (_) tells Solidity to execute the rest of the function body here
        _;
    }

    /**
     * @dev Updates the migration counter.
     * @param completed The ID of the migration script that just finished.
     */
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }
}