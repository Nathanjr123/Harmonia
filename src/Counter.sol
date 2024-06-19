// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Counter {
    enum Interest { Sport, Books, Nature, Animals, Work }

    struct Profile {
        string name;
        uint8 age;
        bool gender; // M or F true for male and false for female
        string country;
        Interest interest;
    }

    mapping(address => Profile) public profiles;
    mapping(address => mapping(address => bool)) public connections; // Tracks connections between users
    uint256 public numberOfProfiles;  // Counter for profiles
    mapping(address => mapping(address => bool)) public matches;  // Tracks matches between users

    event ProfileSet(
        address indexed user,
        string name,
        uint8 age,
        bool gender,
        string country,
        Interest interest
    );

    event MatchMade(
        address indexed user,
        address indexed matchedWith
    );

    event Connected(
        address indexed user,
        address indexed connectedWith
    );

    function setProfile(
        string memory _name,
        uint8 _age,
        bool _gender,
        string memory _country,
        Interest _interest
    ) public {
        if (bytes(profiles[msg.sender].name).length == 0) {
            numberOfProfiles++;  // Increment counter if new profile
        }

        profiles[msg.sender] = Profile({
            name: _name,
            age: _age,
            gender: _gender,
            country: _country,
            interest: _interest
        });

        emit ProfileSet(msg.sender, _name, _age, _gender, _country, _interest);
    }

    function getProfile(
        address _user
    ) public view returns (string memory, uint8, bool, string memory, Interest) {
        Profile memory profile = profiles[_user];
        return (profile.name, profile.age, profile.gender, profile.country, profile.interest);
    }

    function matchWith(address _user) public {
        require(msg.sender != _user, "You cannot match with yourself");
        require(bytes(profiles[_user].name).length != 0, "User profile does not exist");

        matches[msg.sender][_user] = true;
        emit MatchMade(msg.sender, _user);
    }

    function hasMatched(address _user1, address _user2) public view returns (bool) {
        return matches[_user1][_user2];
    }

    function connectWith(address _user) public {
        require(bytes(profiles[_user].name).length != 0, "User profile does not exist");
        require(msg.sender != _user, "You cannot connect with yourself");

        connections[msg.sender][_user] = true;
        connections[_user][msg.sender] = true;

        emit Connected(msg.sender, _user);
    }

    function isConnectedWith(address _user1, address _user2) public view returns (bool) {
        return connections[_user1][_user2];
    }
}
