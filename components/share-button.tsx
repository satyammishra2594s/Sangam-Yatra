'use client';

export function ShareButton({title}:{title:string}) {
  async function share() {
    const url = window.location.href;
    if (navigator.share) {
      await navigator.share({title,url});
      return;
    }
    await navigator.clipboard?.writeText(url);
  }

  return (
    <button type="button" className="btn btn-ghost flex-1" onClick={share}>
      ↗ Share
    </button>
  );
}
