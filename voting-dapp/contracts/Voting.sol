pragma solidity >=0.4.0 <0.9.0;

/**
 * @title Election
 * @dev Implements a basic voting system with administrative controls and state management.
 */
contract Election {
    
    // --- State Definitions ---

    // Defines the lifecycle of the election
    enum State {
        NotStarted, // 0
        InProgress, // 1
        Ended       // 2
    }

    // Structure to store candidate information
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // Structure for voter metadata (Note: currently not fully utilized in mappings)
    struct Voter {
        uint256 id;
        string name;
    }

    // --- State Variables ---

    address public owner;           // Address of the contract deployer (Administrator)
    State public electionState;     // Current status of the election

    // Mappings for data storage
    mapping(uint256 => Candidate) candidates; // Maps candidate ID to Candidate data
    mapping(address => bool) voted;           // Tracks if an address has already voted
    mapping(address => bool) isVoter;         // Whitelist of authorized voters

    uint256 public candidatesCount = 0;       // Total number of candidates
    uint256 public votersCount = 0;           // Total number of authorized voters (intended use)

    // --- Events ---

    // Triggered whenever a successful vote is cast
    event Voted(uint256 indexed _candidateId);

    /**
     * @dev Sets the contract owner and initializes the election with default candidates.
     */
    constructor() {
        owner = msg.sender;
        electionState = State.NotStarted;
        
        // Initial setup
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    // --- Administrative Functions ---

    /**
     * @dev Changes state to InProgress. Only owner can call this before the election starts.
     */
    function startElection() public {
        require(msg.sender == owner, "Only owner can start");
        require(electionState == State.NotStarted, "Election already started or ended");
        electionState = State.InProgress;
    }

    /**
     * @dev Changes state to Ended. Only owner can call this while election is InProgress.
     */
    function endElection() public {
        require(msg.sender == owner, "Only owner can end");
        require(electionState == State.InProgress, "Election is not in progress");
        electionState = State.Ended;
    }

    /**
     * @dev Adds a new candidate to the mapping.
     * @param _name Name of the candidate.
     */
    function addCandidate(string memory _name) public {
        require(owner == msg.sender, "Only owner can add candidates");
        require(
            electionState == State.NotStarted,
            "Election has already started"
        );

        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        candidatesCount++;
    }

    /**
     * @dev Authorizes an address to participate in the election.
     * @param _voter The wallet address to be whitelisted.
     */
    function addVoter(address _voter) public {
        require(owner == msg.sender, "Only owner can add voter");
        require(!isVoter[_voter], "Voter already added");
        require(
            electionState == State.NotStarted,
            "Voter can't be added after election started"
        );

        isVoter[_voter] = true;
    }

    // --- Utility / View Functions ---

    /**
     * @dev Identifies the role of a given address for frontend logic.
     * @return 1 for Admin, 2 for Authorized Voter, 3 for Guest/Unauthorized.
     */
    function getRole(address _current) public view returns (uint256) {
        if (owner == _current) {
            return 1;
        } else if (isVoter[_current]) {
            return 2;
        } else {
            return 3;
        }
    }

    /**
     * @dev Allows an authorized user to cast a vote for a candidate.
     * @param _candidateId The ID of the candidate being voted for.
     */
    function vote(uint256 _candidateId) public {
        // Check if the election is active
        require(
            electionState == State.InProgress,
            "Election is not in progress"
        );
        // Check if user is whitelisted
        require(isVoter[msg.sender], "Non authorised user cannot vote");
        // Check if user has already voted
        require(!voted[msg.sender], "You have already voted");
        // Validate candidate ID exists
        require(
            _candidateId >= 0 && _candidateId < candidatesCount,
            "Invalid candidate ID"
        );

        // Record the vote
        candidates[_candidateId].voteCount++;
        voted[msg.sender] = true;

        // Emit event for off-chain listening (dApps/Indexers)
        emit Voted(_candidateId);
    }

    /**
     * @dev Fetches candidate data.
     * @return Name and current vote count of the candidate.
     */
    function getCandidateDetails(uint256 _candidateId)
        public
        view
        returns (string memory, uint256)
    {
        require(
            _candidateId >= 0 && _candidateId < candidatesCount,
            "Invalid candidate ID"
        );
        return (
            candidates[_candidateId].name,
            candidates[_candidateId].voteCount
        );
    }
}