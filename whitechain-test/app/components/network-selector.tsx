'use client';

import { NETWORKS } from '@/utils/contract.addresses';

interface NetworkSelectorProps {
  currentNetwork: string | null;
  onNetworkChange: (networkId: string) => void;
  disabled: boolean;
}

export default function NetworkSelector({ 
  currentNetwork, 
  onNetworkChange, 
  disabled 
}: NetworkSelectorProps) {
  return (
    <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 mb-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div className="mb-3 sm:mb-0">
          <h3 className="font-medium text-gray-800">Поточна мережа</h3>
          <p className="text-sm text-gray-600">
            {currentNetwork ? NETWORKS[currentNetwork as keyof typeof NETWORKS]?.name : 'Не вибрано'}
          </p>
        </div>
        <div className="flex space-x-3">
          <button
            onClick={() => onNetworkChange('sepolia')}
            disabled={disabled || currentNetwork === 'sepolia'}
            className={`px-4 py-2 rounded text-sm ${
              disabled ? 'bg-gray-300 text-gray-500 cursor-not-allowed' :
              currentNetwork === 'sepolia' ? 'bg-blue-500 text-white' : 'bg-gray-200 hover:bg-gray-300 text-gray-800'
            }`}
          >
            Sepolia
          </button>
          <button
            onClick={() => onNetworkChange('whitechain')}
            disabled={disabled || currentNetwork === 'whitechain'}
            className={`px-4 py-2 rounded text-sm ${
              disabled ? 'bg-gray-300 text-gray-500 cursor-not-allowed' :
              currentNetwork === 'whitechain' ? 'bg-green-500 text-white' : 'bg-gray-200 hover:bg-gray-300 text-gray-800'
            }`}
          >
            Whitechain
          </button>
        </div>
      </div>
    </div>
  );
}