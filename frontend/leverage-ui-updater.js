// Dynamic UI updater for leverage direction and required asset

function updateLeverageUI() {
  const leverage = currentLeverage || 0;
  const isLong = leverage > 0;
  const isShort = leverage < 0;
  const selectedAsset = document.querySelector('.asset-btn.active')?.dataset.asset || 'wQQQx';
  const assetName = selectedAsset === 'wSPYx' ? 'SPY' : 'QQQ';
  const wrappedToken = selectedAsset === 'wSPYx' ? 'wSPYx' : 'wQQQx';
  
  // Update label - wrapped token for long, USDC for short
  const label = document.getElementById('positionAmountLabel');
  if (label) {
    if (isLong) {
      label.textContent = `Deposit Amount (${wrappedToken})`;
      label.style.color = 'rgba(16, 185, 129, 0.8)';
    } else if (isShort) {
      label.textContent = `Deposit Amount (USDC)`;
      label.style.color = 'rgba(239, 68, 68, 0.8)';
    } else {
      label.textContent = `Deposit Amount`;
      label.style.color = 'rgba(255,255,255,0.6)';
    }
  }
  
  // Update info text - explain what you need
  const info = document.getElementById('assetRequirementInfo');
  const absLev = Math.abs(leverage);
  if (info) {
    if (isLong) {
      info.innerHTML = `ℹ️ Long: Deposit ${wrappedToken}, borrow USDC, loop for ${absLev.toFixed(1)}x exposure`;
      info.style.color = 'rgba(16, 185, 129, 0.8)';
    } else if (isShort) {
      info.innerHTML = `ℹ️ Short: Deposit USDC, borrow ${wrappedToken}, loop for ${absLev.toFixed(1)}x exposure`;
      info.style.color = 'rgba(239, 68, 68, 0.8)';
    } else {
      info.innerHTML = `ℹ️ Select leverage direction to see requirements`;
      info.style.color = 'rgba(102, 126, 234, 0.8)';
    }
  }
  
  // Update placeholder
  const input = document.getElementById('positionAmountInput');
  if (input) {
    if (isLong) {
      input.placeholder = `Enter ${wrappedToken} amount`;
    } else if (isShort) {
      input.placeholder = `Enter USDC amount`;
    } else {
      input.placeholder = `Enter amount`;
    }
  }
  
  // Update button text
  const btn = document.getElementById('openPositionBtn');
  if (btn && !btn.disabled) {
    if (isLong) {
      btn.textContent = `Open ${Math.abs(leverage).toFixed(1)}× Long (${assetName})`;
    } else if (isShort) {
      btn.textContent = `Open ${Math.abs(leverage).toFixed(1)}× Short (${assetName})`;
    } else {
      btn.textContent = `Open Position`;
    }
  }
}

// Call this whenever leverage changes
if (typeof window !== 'undefined') {
  window.updateLeverageUI = updateLeverageUI;
  
  // Update on page load
  document.addEventListener('DOMContentLoaded', () => {
    updateLeverageUI();
  });
}
