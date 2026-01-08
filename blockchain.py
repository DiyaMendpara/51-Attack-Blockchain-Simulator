import hashlib
import json
import time
from typing import List, Dict, Optional


class Transaction:
    def __init__(self, sender: str, recipient: str, amount: float, id: int = None, ratings: float = None, description: str = "", status: str = "pending", category: str = ""): 
        self.sender = sender
        self.recipient = recipient
        self.amount = float(amount)
        self.id = id if id is not None else int(time.time() * 1000)  # unique-ish id
        self.timestamp = time.time()
        self.ratings = ratings if ratings is not None else 0.0
        self.description = description
        self.status = status
        self.category = category

    def to_dict(self) -> Dict[str, str]:
        return {
            "id": self.id,
            "timestamp": self.timestamp,
            "sender": self.sender,
            "recipient": self.recipient,
            "amount": self.amount,
            "ratings": self.ratings,
            "description": self.description,
            "status": self.status,
            "category": self.category,
        }


class Block:
    def __init__(self, index: int, timestamp: float, transactions: List[Dict], proof: int, previous_hash: str, block_id: int = None, block_ratings: float = None, miner: str = "", notes: str = ""):
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.proof = proof
        self.previous_hash = previous_hash
        self.block_id = block_id if block_id is not None else int(time.time() * 1000)
        self.block_ratings = block_ratings if block_ratings is not None else 0.0
        self.miner = miner
        self.notes = notes

    def to_dict(self) -> Dict:
        return {
            "block_id": self.block_id,
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "proof": self.proof,
            "previous_hash": self.previous_hash,
            "hash": self.hash_block(),
            "block_ratings": self.block_ratings,
            "miner": self.miner,
            "notes": self.notes,
        }

    def hash_block(self) -> str:
        block_string = json.dumps({
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "proof": self.proof,
            "previous_hash": self.previous_hash,
        }, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()


class Blockchain:
    def __init__(self, difficulty_prefix: str = "0000"):
        self.current_transactions: List[Transaction] = []
        self.chain: List[Block] = []
        self.difficulty_prefix = difficulty_prefix
        # Create genesis block
        self.new_block(proof=100, previous_hash="1")

    def new_block(self, proof: int, previous_hash: Optional[str] = None, miner: str = "", notes: str = "") -> Block:
        block = Block(
            index=len(self.chain) + 1,
            timestamp=time.time(),
            transactions=[t.to_dict() for t in self.current_transactions],
            proof=proof,
            previous_hash=previous_hash or (self.chain[-1].hash_block() if self.chain else "1"),
            miner=miner,
            notes=notes
        )
        self.current_transactions = []
        self.chain.append(block)
        return block

    def new_transaction(self, sender: str, recipient: str, amount: float, id: int = None, ratings: float = None, description: str = "", status: str = "pending", category: str = "") -> int:
        tx = Transaction(sender, recipient, amount, id=id, ratings=ratings, description=description, status=status, category=category)
        self.current_transactions.append(tx)
        return self.last_block.index + 1

    @property
    def last_block(self) -> Block:
        return self.chain[-1]

    def proof_of_work(self, last_proof: int, last_hash: str) -> int:
        proof = 0
        while not self.valid_proof(last_proof, proof, last_hash):
            proof += 1
        return proof

    def valid_proof(self, last_proof: int, proof: int, last_hash: str) -> bool:
        guess = f"{last_proof}{proof}{last_hash}".encode()
        guess_hash = hashlib.sha256(guess).hexdigest()
        return guess_hash.startswith(self.difficulty_prefix)

    def to_dict(self) -> Dict:
        return {
            "length": len(self.chain),
            "chain": [b.to_dict() for b in self.chain],
            "mempool": [t.to_dict() for t in self.current_transactions],
            "difficulty_prefix": self.difficulty_prefix,
        }

