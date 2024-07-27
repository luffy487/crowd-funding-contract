//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract CrowdFunding {
    struct Project {
        address payable creator;
        uint256 projectId;
        string description;
        uint256 goal;
        uint256 amountRaised;
        uint256 deadline;
        bool goalReached;
        bool withdrawn;
        mapping(address => uint256) contributions;
    }
    uint256 ProjectCount;
    mapping(uint256 => Project) private allProjects;
    event ProjectCreated(
        uint256 indexed projectId,
        address creator,
        uint256 goal
    );
    event Contributed(
        uint256 indexed projectId,
        address contributor,
        uint256 amount
    );
    event GoalReached(uint256 projectId);
    modifier onlyCreator(uint256 _projectId) {
        require(
            msg.sender == allProjects[_projectId].creator,
            "You must be creator of the project"
        );
        _;
    }
    modifier onlyContributor(uint256 _projectId) {
        require(allProjects[_projectId].contributions[msg.sender] > 0, "You must be a contributor to the project");
        _;
    }
    modifier validProjectId(uint256 _projectId) {
        require(_projectId > 0);
        require(_projectId <= ProjectCount);
        _;
    }
    function createProject(
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) external {
        require(_goal > 0, "Goal should be greater than 0");
        ProjectCount = ProjectCount + 1;
        Project storage newProject = allProjects[ProjectCount];
        newProject.creator = payable(msg.sender);
        newProject.projectId = ProjectCount;
        newProject.goal = _goal;
        newProject.description = _description;
        newProject.amountRaised = 0;
        newProject.goalReached = false;
        newProject.deadline = _deadline;
        newProject.withdrawn = false;
        emit ProjectCreated(ProjectCount, msg.sender, _goal);
    }

    function contribute(uint256 _projectId) external payable validProjectId(_projectId){
        Project storage project = allProjects[_projectId];
        require(msg.value > 0, "Contribution must be greater than 0");
        require(!project.goalReached, "Project goal already reached.");
        require(block.timestamp < project.deadline, "Already reached the deadline");
        project.amountRaised += msg.value;
        project.contributions[msg.sender] += msg.value;
        emit Contributed(_projectId, msg.sender, msg.value);
        if (project.amountRaised >= project.goal) {
            project.goalReached = true;
            emit GoalReached(_projectId);
        }
    }

    function withdraw(
        uint256 _projectId
    ) external validProjectId(_projectId) onlyCreator(_projectId) returns (bool) {
        Project storage project = allProjects[_projectId];
        require(block.timestamp > project.deadline, "Deadline not reached yet");
        require(project.goalReached, "Project goal not reached yet");
        require(!project.withdrawn, "Funds already withdrawn");
        project.withdrawn = true;
        bool sent = payable(msg.sender).send(project.amountRaised);
        if(!sent){
            project.withdrawn = false;
            return false;
        }
        return true;
    }

    function refund(uint256 _projectId) external validProjectId(_projectId) onlyContributor(_projectId) returns(bool){
        Project storage project = allProjects[_projectId];
        require(!project.withdrawn, "Sorry you can't get a refund as the funds are withdrawn already");
        uint256 amount = project.contributions[msg.sender];
        project.amountRaised -= project.contributions[msg.sender];
        project.contributions[msg.sender] = 0;
        bool sent = payable(msg.sender).send(amount);
        if(!sent){
            project.amountRaised += amount;
            project.contributions[msg.sender] += amount;
            return false;
        }
        return true;
    }

    function getProjectCreator(uint256 _projectId) view external returns(address){
        Project storage project = allProjects[_projectId];
        return project.creator;
    }

    function getProjectGoal(uint256 _projectId) view external returns(uint256){
        Project storage project = allProjects[_projectId];
        return project.goal;
    }

    function getProjectAmountRaised(uint256 _projectId) view external returns(uint256){
        Project storage project = allProjects[_projectId];
        return project.amountRaised;
    }

    function getProjectDeadline(uint256 _projectId) view external returns(uint256) {
        Project storage project = allProjects[_projectId];
        return project.deadline;
    }
    function getProjectDeadlineReached(uint256 _projectId) view external returns(bool) {
        Project storage project = allProjects[_projectId];
        if(block.timestamp > project.deadline){
            return true;
        }
        return false;
    }

    function getProjectGoalReached(uint256 _projectId) view external returns(bool){
        Project storage project = allProjects[_projectId];
        return project.goalReached;
    }
    
    function getProjectFundsWithdrawn(uint256 _projectId) view external returns(bool) {
        Project storage project = allProjects[_projectId];
        return project.withdrawn;
    }

    function getContribution(uint256 _projectId, address _contributor) view external returns(uint256) {
        Project storage project = allProjects[_projectId];
        return project.contributions[_contributor];
    }
}
