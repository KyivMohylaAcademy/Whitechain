'use client';

import { useEffect, useState, useCallback } from 'react';
import { ethers } from 'ethers';

interface VotingInfo {
  id: number;
  description: string;
  startTime: Date;
  endTime: Date;
  option1: string;
  option2: string;
  isActive: boolean;
  option1Votes?: number;
  option2Votes?: number;
}

interface VotingPanelProps {
  votingContract: ethers.Contract | null;
  walletAddress: string | null;
}

export default function VotingPanel({ votingContract, walletAddress }: VotingPanelProps) {
  const [votingList, setVotingList] = useState<VotingInfo[]>([]);
  const [hasVoted, setHasVoted] = useState<{[key: number]: boolean}>({});
  const [votingResults, setVotingResults] = useState<{[key: number]: {winner: number, option1Votes: number, option2Votes: number}}>({});
  const [loading, setLoading] = useState(false);
  const [loadingVote, setLoadingVote] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [debugInfo, setDebugInfo] = useState<string>("");
  
  const loadAllVotings = useCallback(async () => {
    if (!votingContract) {
      setDebugInfo("Контракт голосування недоступний");
      return;
    }
    
    setDebugInfo("▶️ Початок завантаження голосувань");
    setLoading(true);
    setError(null);
    
    try {
      const currentId = await votingContract.getCurrentVotingId();
      setDebugInfo(prev => prev + `\nЗагальна кількість голосувань: ${currentId.toString()}`);
      
      const votings: VotingInfo[] = [];
      const votedStatus: {[key: number]: boolean} = {};
      const results: {[key: number]: {winner: number, option1Votes: number, option2Votes: number}} = {};
      
      for (let i = 0; i < Number(currentId); i++) {
        try {
          const details = await votingContract.getVotingDetails(i);
          
          const voting: VotingInfo = {
            id: i,
            description: details[0],
            startTime: new Date(Number(details[1]) * 1000),
            endTime: new Date(Number(details[2]) * 1000),
            option1: details[3],
            option2: details[4],
            isActive: details[5]
          };
          
          votings.push(voting);
          setDebugInfo(prev => prev + `\nДодано голосування #${i}: ${voting.description}`);
          
          if (walletAddress) {
            const voted = await votingContract.hasVoted(i, walletAddress);
            votedStatus[i] = voted;
            
            if (voted) {
              try {
                const votingResult = await votingContract.getVotingResults(i);
                results[i] = {
                  winner: Number(votingResult[0]),
                  option1Votes: Number(votingResult[1]),
                  option2Votes: Number(votingResult[2])
                };
              } catch (error) {
                setDebugInfo(prev => prev + `\nПомилка отримання результатів для #${i}`);
              }
            }
          }
        } catch (error) {
          setDebugInfo(prev => prev + `\nПомилка отримання даних для #${i}`);
        }
      }
      
      setDebugInfo(prev => prev + `\nЗавершено. Знайдено ${votings.length} голосувань`);
      
      if (votings.length > 0) {
        setVotingList(votings);
        setHasVoted(votedStatus);
        setVotingResults(results);
      } else {
        setDebugInfo(prev => prev + "\nГолосувань не знайдено");
      }
    } catch (error: any) {
      setError(`Помилка при завантаженні даних: ${error.message}`);
      setDebugInfo(prev => prev + `\nПомилка: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }, [votingContract, walletAddress]);
  
  useEffect(() => {
    if (votingContract) {
      loadAllVotings();
    } else {
      setDebugInfo("Контракт голосування недоступний");
    }
  }, [votingContract, walletAddress, loadAllVotings]);
  
  const handleVote = async (votingId: number, option: number) => {
    if (!votingContract) return;
    
    setLoadingVote(votingId);
    setError(null);
    
    try {
      const tx = await votingContract.vote(votingId, option);
      setDebugInfo(prev => prev + `\nВідправлено голос за опцію ${option} у #${votingId}`);
      
      await tx.wait();
      setDebugInfo(prev => prev + `\nГолос зараховано`);
      
      const newHasVoted = { ...hasVoted };
      newHasVoted[votingId] = true;
      setHasVoted(newHasVoted);
      
      try {
        const votingResult = await votingContract.getVotingResults(votingId);
        const newResults = { ...votingResults };
        newResults[votingId] = {
          winner: Number(votingResult[0]),
          option1Votes: Number(votingResult[1]),
          option2Votes: Number(votingResult[2])
        };
        setVotingResults(newResults);
      } catch (error) {
        setDebugInfo(prev => prev + `\nПомилка отримання результатів`);
      }
      
      const votingInfo = votingList.find(v => v.id === votingId);
      alert(`Ви успішно проголосували за опцію ${option === 1 ? votingInfo?.option1 : votingInfo?.option2}! Ви отримали NFT винагороду.`);
    } catch (error: any) {
      setError(error.message || "Помилка при голосуванні. Спробуйте знову.");
      setDebugInfo(prev => prev + `\nПомилка при голосуванні: ${error.message}`);
    } finally {
      setLoadingVote(null);
    }
  };

  const testGetCurrentVotingId = async () => {
    if (!votingContract) {
      setDebugInfo("Контракт недоступний");
      return;
    }
    
    try {
      setDebugInfo("▶️ Тестовий запит getCurrentVotingId...");
      const id = await votingContract.getCurrentVotingId();
      setDebugInfo(prev => `${prev}\ngetCurrentVotingId повернув: ${id}`);
    } catch (error: any) {
      setDebugInfo(prev => `${prev}\nПомилка: ${error.message}`);
    }
  };

  const checkContractMethods = () => {
    if (!votingContract) {
      setDebugInfo("Контракт недоступний");
      return;
    }

    setDebugInfo("Перевірка інтерфейсу контракту...\n");
    
    const methods = Object.keys(votingContract.interface.functions)
      .filter(fn => !fn.includes('('))
      .join(', ');
    
    setDebugInfo(prev => `${prev}\nДоступні методи: ${methods}`);

    votingContract.getAddress().then(address => {
      setDebugInfo(prev => `${prev}\nАдреса контракту: ${address}`);
    });
  };
  
  const DebugPanel = () => (
    <div className="mt-6 border-t pt-4">
      <h3 className="text-lg font-semibold mb-2">Діагностика</h3>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 mb-3">
        <button 
          onClick={loadAllVotings}
          className="px-2 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm"
        >
          Оновити голосування
        </button>
        <button 
          onClick={testGetCurrentVotingId}
          className="px-2 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm"
        >
          Тест getCurrentVotingId
        </button>
        <button 
          onClick={checkContractMethods}
          className="px-2 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm"
        >
          Перевірити методи контракту
        </button>
      </div>
      <div className="p-3 bg-gray-100 rounded-md text-xs font-mono overflow-auto max-h-60">
        <pre>{debugInfo || "Немає даних для відображення"}</pre>
      </div>
      <div className="mt-2 text-xs text-gray-500">
        Contract: {votingContract?.target || "Не підключено"}
      </div>
    </div>
  );
  
  if (loading && votingList.length === 0) {
    return (
      <div>
        <div className="flex items-center justify-center p-8 border rounded-lg bg-gray-50">
          <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500 mr-3"></div>
          <p>Завантаження голосувань...</p>
        </div>
        <DebugPanel />
      </div>
    );
  }
  
  if (error) {
    return (
      <div>
        <div className="p-4 border rounded-lg bg-red-50 text-red-700">
          <p className="font-semibold">Помилка:</p>
          <p>{error}</p>
          <button 
            onClick={loadAllVotings} 
            className="mt-3 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            Спробувати знову
          </button>
        </div>
        <DebugPanel />
      </div>
    );
  }
  
  return (
    <div>
      <div className="border rounded-lg overflow-hidden">
        <div className="bg-blue-500 text-white p-4 flex justify-between items-center">
          <h2 className="text-xl font-bold">Голосування {votingList.length > 0 ? `(${votingList.length})` : ""}</h2>
          <button 
            onClick={loadAllVotings} 
            className="px-3 py-1 bg-white text-blue-500 rounded hover:bg-blue-50"
          >
            Оновити
          </button>
        </div>
        
        <div className="p-4">
          {votingList.length === 0 ? (
            <div className="p-6 text-center">
              <p className="text-lg text-gray-700">Голосувань не знайдено</p>
              <p className="mt-2 text-sm text-gray-500">Переконайтеся, що ви підключені до правильної мережі, або створіть нове голосування</p>
            </div>
          ) : (
            votingList.sort((a, b) => {
              if (a.isActive && !b.isActive) return -1;
              if (!a.isActive && b.isActive) return 1;
              return b.endTime.getTime() - a.endTime.getTime();
            }).map(voting => {
              const isEnded = voting.endTime.getTime() <= Date.now();
              const userHasVoted = hasVoted[voting.id] || false;
              const result = votingResults[voting.id];
              
              return (
                <div 
                  key={voting.id}
                  className={`mb-6 p-4 border rounded-lg ${voting.isActive ? 'border-blue-200 bg-blue-50' : 'border-gray-200'}`}
                >
                  <div className="flex justify-between items-start mb-2">
                    <h3 className="text-lg font-semibold">{voting.description}</h3>
                    <span 
                      className={`inline-block px-3 py-1 text-xs rounded-full ${
                        (voting.isActive && voting.endTime.getTime() > Date.now()) 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}
                    >
                      {(voting.isActive && voting.endTime.getTime() > Date.now()) ? 'Активне' : 'Завершено'}
                    </span>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3 text-sm">
                    <div className="bg-white p-2 rounded">
                      <p className="font-medium">Початок:</p>
                      <p>{voting.startTime.toLocaleString()}</p>
                    </div>
                    <div className="bg-white p-2 rounded">
                      <p className="font-medium">Кінець:</p>
                      <p>{voting.endTime.toLocaleString()}</p>
                    </div>
                  </div>
                  
                  <div className="mb-3 text-center">
                    <span className={`inline-block px-2 py-1 text-xs rounded ${
                      isEnded ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                    }`}>
                      {formatTimeRemaining(voting.endTime)}
                    </span>
                  </div>
                  
                  {userHasVoted || isEnded ? (
                    <div>
                      {userHasVoted && (
                        <div className="mb-3 py-1 px-2 bg-green-50 text-green-700 text-sm rounded text-center">
                          Ви проголосували в цьому голосуванні
                        </div>
                      )}
                      
                      {result && (
                        <div>
                          <h4 className="text-sm font-medium mb-2">Результати:</h4>
                          
                          <div className="space-y-3">
                            <div className="relative">
                              <div className="flex items-center justify-between mb-1">
                                <span className="text-sm text-blue-600">{voting.option1}</span>
                                <span className="text-xs text-blue-600">
                                  {result.option1Votes} голосів ({result.option1Votes + result.option2Votes > 0 
                                    ? Math.round(result.option1Votes / (result.option1Votes + result.option2Votes) * 100) 
                                    : 0}%)
                                </span>
                              </div>
                              <div className="h-2 bg-blue-100 rounded">
                                <div 
                                  className="h-full bg-blue-500 rounded" 
                                  style={{
                                    width: `${result.option1Votes + result.option2Votes > 0 
                                      ? (result.option1Votes / (result.option1Votes + result.option2Votes) * 100) 
                                      : 0}%`
                                  }}
                                ></div>
                              </div>
                            </div>
                            
                            <div className="relative">
                              <div className="flex items-center justify-between mb-1">
                                <span className="text-sm text-red-600">{voting.option2}</span>
                                <span className="text-xs text-red-600">
                                  {result.option2Votes} голосів ({result.option1Votes + result.option2Votes > 0 
                                    ? Math.round(result.option2Votes / (result.option1Votes + result.option2Votes) * 100) 
                                    : 0}%)
                                </span>
                              </div>
                              <div className="h-2 bg-red-100 rounded">
                                <div 
                                  className="h-full bg-red-500 rounded" 
                                  style={{
                                    width: `${result.option1Votes + result.option2Votes > 0 
                                      ? (result.option2Votes / (result.option1Votes + result.option2Votes) * 100) 
                                      : 0}%`
                                  }}
                                ></div>
                              </div>
                            </div>
                          </div>
                          
                          {result.winner > 0 && (
                            <p className="mt-2 text-sm text-center font-medium">
                              {isEnded ? 'Переможець' : 'Лідер'}: {result.winner === 1 ? voting.option1 : voting.option2}
                            </p>
                          )}
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="mt-3">
                      <p className="text-sm text-center mb-3">Оберіть варіант для голосування:</p>
                      
                      <div className="grid grid-cols-2 gap-3">
                        <button
                          onClick={() => handleVote(voting.id, 1)}
                          disabled={loadingVote === voting.id}
                          className={`py-2 text-white text-center rounded ${
                            loadingVote === voting.id ? 'bg-gray-400' : 'bg-blue-500 hover:bg-blue-600'
                          }`}
                        >
                          {voting.option1}
                        </button>
                        <button
                          onClick={() => handleVote(voting.id, 2)}
                          disabled={loadingVote === voting.id}
                          className={`py-2 text-white text-center rounded ${
                            loadingVote === voting.id ? 'bg-gray-400' : 'bg-red-500 hover:bg-red-600'
                          }`}
                        >
                          {voting.option2}
                        </button>
                      </div>
                      
                      <p className="mt-2 text-center text-xs text-gray-500">
                        Після голосування ви отримаєте NFT винагороду
                      </p>
                    </div>
                  )}
                  
                  <div className="mt-3 text-xs text-gray-500 text-right">
                    ID голосування: {voting.id}
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
      
      <DebugPanel />
    </div>
  );
  
  function formatTimeRemaining(endTime: Date) {
    const timeRemaining = endTime.getTime() - Date.now();
    if (timeRemaining <= 0) return "Завершено";
    
    const hours = Math.floor(timeRemaining / (1000 * 60 * 60));
    const minutes = Math.floor((timeRemaining % (1000 * 60 * 60)) / (1000 * 60));
    
    return `${hours}год ${minutes}хв залишилось`;
  }
}