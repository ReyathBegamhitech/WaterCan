import React, { useState, useEffect } from 'react';

export default function CountUp({ value, duration = 1000 }) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    let startTime = null;
    const endValue = parseFloat(value) || 0;
    
    if (endValue === 0) {
      setCount(0);
      return;
    }

    const step = (timestamp) => {
      if (!startTime) startTime = timestamp;
      const progress = timestamp - startTime;
      const percentage = Math.min(progress / duration, 1);
      
      // easeOutQuart easing for smooth deceleration
      const ease = 1 - Math.pow(1 - percentage, 4);
      
      setCount(endValue * ease);
      
      if (percentage < 1) {
        window.requestAnimationFrame(step);
      } else {
        setCount(endValue);
      }
    };

    window.requestAnimationFrame(step);
  }, [value, duration]);

  return <span>{Math.round(count)}</span>;
}
